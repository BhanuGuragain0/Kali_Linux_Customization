#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════
    WiFi RECON & AUTO-CONNECT
    Developed by Bhanu GUragain (Shadow Junior)
═══════════════════════════════════════════════════════════════════
"""

import os
import sys
import time
import subprocess
import logging
import json
import re
import asyncio
from pathlib import Path
from typing import Dict, Optional, List, Tuple, NamedTuple
from datetime import datetime, timedelta
from logging.handlers import RotatingFileHandler
from dataclasses import dataclass
from enum import Enum

import aiohttp
from cryptography.fernet import Fernet

try:
    import keyring
    KEYRING_AVAILABLE = True
except ImportError:
    KEYRING_AVAILABLE = False

try:
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    from selenium.webdriver.chrome.options import Options as ChromeOptions
    from selenium.webdriver.firefox.options import Options as FirefoxOptions
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC
    from selenium.common.exceptions import TimeoutException, WebDriverException
    SELENIUM_AVAILABLE = True
except ImportError:
    SELENIUM_AVAILABLE = False

# ═══════════════════════════════════════════════════════════════════
# CONFIGURATION & DATA STRUCTURES
# ═══════════════════════════════════════════════════════════════════

class ConnectionState(Enum):
    DISCONNECTED = 0
    SCANNING = 1
    CONNECTING = 2
    CONNECTED = 3
    AUTHENTICATING = 4
    AUTHENTICATED = 5
    FAILED = 6

class WiFiNetwork(NamedTuple):
    """WiFi network information"""
    ssid: str
    bssid: str  # MAC address
    signal: int  # Signal strength (0-100)
    channel: int
    security: str
    frequency: str
    in_use: bool = False

@dataclass
class Config:
    """Master configuration"""
    wifi_patterns: List[str]
    portal_url: str
    username: str
    password: str
    
    # Advanced Options
    max_retries: int = 5
    retry_delay: int = 3
    connection_timeout: int = 15
    portal_timeout: int = 25
    health_check_interval: int = 300
    scan_interval: int = 10
    
    # Signal Strength Thresholds
    min_signal_strength: int = 30
    signal_hysteresis: int = 10
    
    # Stealth Options
    stealth_mode: bool = False
    randomize_mac: bool = False
    silent_mode: bool = False
    debug_mode: bool = False
    
    # Paths
    log_dir: Path = Path.home() / ".wifi_shadow" / "logs"
    cache_dir: Path = Path.home() / ".wifi_shadow" / "cache"
    
    def __post_init__(self):
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.cache_dir.mkdir(parents=True, exist_ok=True)

# ═══════════════════════════════════════════════════════════════════
# CREDENTIAL ENCRYPTION
# ═══════════════════════════════════════════════════════════════════

class SecureCredentials:
    """Military-grade credential encryption using Fernet"""
    
    def __init__(self, keyring_service: str = "shadow_wifi_arsenal"):
        self.service = keyring_service
        self.key = self._get_or_create_key()
        self.cipher = Fernet(self.key)
    
    def _get_or_create_key(self) -> bytes:
        """Retrieve or generate encryption key"""
        if KEYRING_AVAILABLE:
            try:
                key_str = keyring.get_password(self.service, "master_key")
                if key_str:
                    return key_str.encode()
            except Exception:
                pass
        
        # File fallback: reuse existing key if present
        key_file = Path.home() / ".wifi_shadow" / ".key"
        if key_file.exists():
            try:
                key = key_file.read_bytes()
                if key:
                    return key
            except Exception:
                pass

        # Generate new key
        key = Fernet.generate_key()
        
        if KEYRING_AVAILABLE:
            try:
                keyring.set_password(self.service, "master_key", key.decode())
                return key
            except Exception:
                pass
        
        # File fallback (create)
        key_file.parent.mkdir(parents=True, exist_ok=True)
        key_file.write_bytes(key)
        key_file.chmod(0o600)
        return key
    
    def encrypt(self, data: str) -> str:
        return self.cipher.encrypt(data.encode()).decode()
    
    def decrypt(self, encrypted_data: str) -> str:
        return self.cipher.decrypt(encrypted_data.encode()).decode()
    
    def store_credentials(self, username: str, password: str):
        """Store encrypted credentials"""
        enc_user = self.encrypt(username)
        enc_pass = self.encrypt(password)
        
        if KEYRING_AVAILABLE:
            try:
                keyring.set_password(self.service, "enc_username", enc_user)
                keyring.set_password(self.service, "enc_password", enc_pass)
                return
            except Exception:
                pass
        
        # File fallback
        cred_file = Path.home() / ".wifi_shadow" / ".credentials"
        creds = {"username": enc_user, "password": enc_pass}
        cred_file.write_text(json.dumps(creds))
        cred_file.chmod(0o600)
    
    def load_credentials(self) -> Tuple[Optional[str], Optional[str]]:
        """Load and decrypt credentials"""
        if KEYRING_AVAILABLE:
            try:
                enc_user = keyring.get_password(self.service, "enc_username")
                enc_pass = keyring.get_password(self.service, "enc_password")
                if enc_user and enc_pass:
                    return self.decrypt(enc_user), self.decrypt(enc_pass)
            except Exception:
                pass
        
        # File fallback
        try:
            cred_file = Path.home() / ".wifi_shadow" / ".credentials"
            creds = json.loads(cred_file.read_text())
            return self.decrypt(creds["username"]), self.decrypt(creds["password"])
        except Exception:
            pass
        
        return None, None

# ═══════════════════════════════════════════════════════════════════
# WiFi RECONNAISSANCE ENGINE - FIXED
# ═══════════════════════════════════════════════════════════════════

class WiFiRecon:
    """Elite WiFi scanning & signal analysis - FIXED PARSING"""
    
    def __init__(self, logger: logging.Logger, debug: bool = False):
        self.logger = logger
        self.debug = debug
        self.interface = self._detect_interface()
    
    def _detect_interface(self) -> Optional[str]:
        """Auto-detect WiFi interface"""
        try:
            result = subprocess.run(
                ["iw", "dev"],
                capture_output=True,
                text=True,
                timeout=5
            )
            for line in result.stdout.split("\n"):
                if "Interface" in line:
                    return line.split()[-1]
        except Exception:
            pass
        
        # Fallback to common names
        for iface in ["wlan0", "wlp2s0", "wlo1", "wlp3s0", "wlan1"]:
            if Path(f"/sys/class/net/{iface}").exists():
                return iface
        
        return None
    
    def scan_networks(self) -> List[WiFiNetwork]:
        """
        FIXED: Scan for all available WiFi networks with detailed info
        
        CRITICAL FIX:
        - Use LC_ALL=C to force English output (prevents locale issues)
        - Use -t (terse) mode for consistent parsing
        - Fields: IN-USE:BSSID:SSID:CHAN:SIGNAL:SECURITY:FREQ
        - SSID is field index 2 (0-indexed), not 3!
        """
        try:
            # Trigger rescan
            subprocess.run(
                ["nmcli", "dev", "wifi", "rescan"],
                capture_output=True,
                timeout=5,
                env={**os.environ, "LC_ALL": "C"}
            )
            time.sleep(2)  # Wait for scan
            
            # Get detailed network list in TERSE mode
            # CRITICAL: Use LC_ALL=C to ensure consistent English output
            result = subprocess.run(
                ["nmcli", "-t", "-f", "IN-USE,BSSID,SSID,CHAN,SIGNAL,SECURITY,FREQ", "dev", "wifi", "list"],
                capture_output=True,
                text=True,
                timeout=10,
                env={**os.environ, "LC_ALL": "C"}
            )
            
            if result.returncode != 0:
                self.logger.error(f"nmcli failed: {result.stderr}")
                return []
            
            if self.debug:
                self.logger.debug(f"nmcli raw output:\n{result.stdout}")
            
            networks = []
            for line in result.stdout.strip().split("\n"):
                if not line.strip():
                    continue
                
                # Terse mode uses ':' as delimiter, with ':' and '\\' escaped as '\\:' and '\\\\'
                # Split on unescaped ':' and then unescape fields
                parts = re.split(r"(?<!\\):", line)
                parts = [p.replace("\\:", ":").replace("\\\\", "\\") for p in parts]
                
                if self.debug:
                    self.logger.debug(f"Parsing line: {line}")
                    self.logger.debug(f"Parts ({len(parts)}): {parts}")
                
                # Need at least 7 fields: IN-USE:BSSID:SSID:CHAN:SIGNAL:SECURITY:FREQ
                if len(parts) < 7:
                    if self.debug:
                        self.logger.debug(f"Skipping line (insufficient fields): {line}")
                    continue
                
                try:
                    # Parse fields (0-indexed)
                    in_use = parts[0].strip() == "*"
                    bssid = parts[1].strip()
                    ssid = parts[2].strip()  # CRITICAL: SSID is index 2, not 3!
                    channel_str = parts[3].strip()
                    signal_str = parts[4].strip()
                    security = parts[5].strip()
                    freq = parts[6].strip()
                    
                    # Skip if SSID is empty or "--"
                    if not ssid or ssid == "--":
                        if self.debug:
                            self.logger.debug(f"Skipping (no SSID): {line}")
                        continue
                    
                    # Parse signal strength
                    signal = int(signal_str) if signal_str.isdigit() else 0
                    
                    # Parse channel
                    channel = int(channel_str) if channel_str.isdigit() else 0
                    
                    network = WiFiNetwork(
                        ssid=ssid,
                        bssid=bssid,
                        signal=signal,
                        channel=channel,
                        security=security if security else "--",
                        frequency=freq if freq else "Unknown",
                        in_use=in_use
                    )
                    networks.append(network)
                    
                    if self.debug:
                        self.logger.debug(f"✅ Parsed: {network}")
                
                except (ValueError, IndexError) as e:
                    if self.debug:
                        self.logger.debug(f"Parse error on line '{line}': {e}")
                    continue
            
            self.logger.info(f"📡 Scanned {len(networks)} networks")
            return networks
            
        except Exception as e:
            self.logger.error(f"Network scan failed: {e}")
            return []
    
    def find_matching_networks(
        self, 
        networks: List[WiFiNetwork], 
        patterns: List[str]
    ) -> List[WiFiNetwork]:
        """
        Find networks matching SSID patterns
        
        Pattern examples:
        - "STWCU_LR-*" matches STWCU_LR-1, STWCU_LR-2, etc.
        - "STWCU_ICR-*" matches STWCU_ICR-1, STWCU_ICR-2, etc.
        """
        matched = []
        
        for network in networks:
            for pattern in patterns:
                # Convert glob pattern to regex
                # * becomes .* (any chars)
                # ? becomes . (single char)
                regex_pattern = pattern.replace("*", ".*").replace("?", ".")
                regex_pattern = f"^{regex_pattern}$"
                
                if re.match(regex_pattern, network.ssid, re.IGNORECASE):
                    matched.append(network)
                    if self.debug:
                        self.logger.debug(f"✅ Matched '{network.ssid}' with pattern '{pattern}'")
                    break
        
        if self.debug:
            self.logger.debug(f"Found {len(matched)} matching networks")
        
        return matched
    
    def get_best_network(
        self, 
        networks: List[WiFiNetwork],
        current_network: Optional[WiFiNetwork] = None,
        min_signal: int = 30,
        hysteresis: int = 10
    ) -> Optional[WiFiNetwork]:
        """
        Select best network based on signal strength
        
        Hysteresis prevents constant switching:
        - If connected, new network must be significantly better
        - If disconnected, just pick strongest
        """
        if not networks:
            return None
        
        # Filter by minimum signal strength
        viable = [n for n in networks if n.signal >= min_signal]
        if not viable:
            self.logger.warning(f"No networks above {min_signal}% signal threshold")
            return None
        
        # Sort by signal strength (descending)
        viable.sort(key=lambda n: n.signal, reverse=True)
        best = viable[0]
        
        # Apply hysteresis if currently connected
        if current_network and current_network.ssid in [n.ssid for n in viable]:
            current_signal = next((n.signal for n in viable if n.ssid == current_network.ssid), 0)
            
            # Only switch if new network is significantly better
            if best.signal < current_signal + hysteresis:
                self.logger.info(f"Staying with {current_network.ssid} ({current_signal}%) - hysteresis active")
                return current_network
        
        return best

# ═══════════════════════════════════════════════════════════════════
# STEALTH & ANTI-FINGERPRINTING
# ═══════════════════════════════════════════════════════════════════

class StealthTools:
    """Advanced anti-fingerprinting techniques"""
    
    USER_AGENTS = [
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
        "Mozilla/5.0 (X11; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0",
        "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:122.0) Gecko/20100101 Firefox/122.0",
    ]
    
    @staticmethod
    def random_user_agent() -> str:
        import random
        return random.choice(StealthTools.USER_AGENTS)
    
    @staticmethod
    def randomize_mac(interface: str) -> bool:
        """Randomize MAC address"""
        try:
            import random
            subprocess.run(["ip", "link", "set", interface, "down"], 
                         check=True, capture_output=True)
            
            random_mac = "02:%02x:%02x:%02x:%02x:%02x" % tuple(random.randint(0, 255) for _ in range(5))
            
            subprocess.run(["ip", "link", "set", "dev", interface, "address", random_mac],
                         check=True, capture_output=True)
            
            subprocess.run(["ip", "link", "set", interface, "up"],
                         check=True, capture_output=True)
            return True
        except Exception:
            return False
    
    @staticmethod
    def get_stealth_chrome_options() -> ChromeOptions:
        """Chrome with maximum stealth"""
        options = ChromeOptions()
        options.add_argument("--headless=new")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_experimental_option("excludeSwitches", ["enable-automation"])
        options.add_experimental_option("useAutomationExtension", False)
        options.add_argument(f"user-agent={StealthTools.random_user_agent()}")
        options.add_argument("--disable-gpu")
        options.add_argument("--window-size=1920,1080")
        return options
    
    @staticmethod
    def get_stealth_firefox_options() -> FirefoxOptions:
        """Firefox with privacy hardening"""
        options = FirefoxOptions()
        options.add_argument("--headless")
        options.set_preference("general.useragent.override", StealthTools.random_user_agent())
        options.set_preference("privacy.resistFingerprinting", True)
        return options

# ═══════════════════════════════════════════════════════════════════
# NETWORK UTILITIES
# ═══════════════════════════════════════════════════════════════════

class NetworkTools:
    """Network connectivity & captive portal detection"""
    
    @staticmethod
    async def detect_captive_portal(session: aiohttp.ClientSession) -> Tuple[bool, Optional[str]]:
        """Multi-method captive portal detection"""
        endpoints = [
            "http://clients3.google.com/generate_204",
            "http://captive.apple.com/hotspot-detect.html",
            "http://connectivitycheck.gstatic.com/generate_204",
        ]
        
        for endpoint in endpoints:
            try:
                async with session.get(endpoint, timeout=aiohttp.ClientTimeout(total=5), allow_redirects=False) as resp:
                    if resp.status == 204:
                        return False, None
                    
                    if resp.status == 200:
                        content = await resp.text()
                        if len(content) > 0:
                            return True, str(resp.url)
                    
                    if resp.status in [301, 302, 303, 307, 308]:
                        return True, resp.headers.get("Location")
                    
                    if resp.status == 511:
                        return True, str(resp.url)
                        
            except Exception:
                continue
        
        return False, None
    
    @staticmethod
    async def check_internet(session: aiohttp.ClientSession) -> bool:
        """Verify full internet connectivity"""
        endpoints = [
            "http://clients3.google.com/generate_204",
            "http://connectivitycheck.gstatic.com/generate_204",
        ]

        for endpoint in endpoints:
            try:
                async with session.get(
                    endpoint,
                    timeout=aiohttp.ClientTimeout(total=5),
                    allow_redirects=False,
                ) as resp:
                    if resp.status == 204:
                        return True
                    if resp.status in {200, 301, 302, 303, 307, 308, 511}:
                        return False
            except Exception:
                continue

        return False

# ═══════════════════════════════════════════════════════════════════
# CONNECTION MANAGER
# ═══════════════════════════════════════════════════════════════════

class ConnectionManager:
    """WiFi connection orchestration"""
    
    def __init__(self, config: Config, recon: WiFiRecon, logger: logging.Logger):
        self.config = config
        self.recon = recon
        self.logger = logger
        self.state = ConnectionState.DISCONNECTED
        self.current_network: Optional[WiFiNetwork] = None
    
    def _run_nmcli(self, args: List[str], timeout: int = 15) -> Tuple[bool, str]:
        """Execute nmcli command"""
        try:
            result = subprocess.run(
                ["nmcli"] + args,
                capture_output=True,
                text=True,
                timeout=timeout,
                env={**os.environ, "LC_ALL": "C"}
            )
            return result.returncode == 0, result.stdout
        except Exception as e:
            return False, str(e)
    
    def connect_to_network(self, network: WiFiNetwork) -> bool:
        """Connect to specific network"""
        self.logger.info(f"🔌 Connecting to: {network.ssid} (Signal: {network.signal}%)")
        
        self.state = ConnectionState.CONNECTING
        
        # MAC randomization
        if self.config.randomize_mac and self.recon.interface:
            if StealthTools.randomize_mac(self.recon.interface):
                self.logger.info("🎭 MAC address randomized")
        
        success, output = self._run_nmcli(
            ["dev", "wifi", "connect", network.ssid],
            timeout=self.config.connection_timeout
        )
        
        if success:
            self.current_network = network
            self.state = ConnectionState.CONNECTED
            self.logger.info(f"✅ Connected to {network.ssid}")
            return True
        
        self.state = ConnectionState.FAILED
        self.logger.error(f"❌ Connection failed: {output}")
        return False
    
    def auto_connect_best(self) -> bool:
        """Scan and connect to best available network"""
        self.state = ConnectionState.SCANNING
        
        # Scan networks
        all_networks = self.recon.scan_networks()
        if not all_networks:
            self.logger.error("❌ No networks found")
            return False
        
        # Find matching networks
        matched = self.recon.find_matching_networks(all_networks, self.config.wifi_patterns)
        if not matched:
            self.logger.error(f"❌ No networks matching patterns: {self.config.wifi_patterns}")
            self.logger.info(f"💡 Available networks: {[n.ssid for n in all_networks[:10]]}")
            return False
        
        self.logger.info(f"📡 Found {len(matched)} matching networks:")
        for net in sorted(matched, key=lambda n: n.signal, reverse=True)[:5]:
            self.logger.info(f"  - {net.ssid}: {net.signal}% signal")
        
        # Select best network
        best = self.recon.get_best_network(
            matched,
            self.current_network,
            self.config.min_signal_strength,
            self.config.signal_hysteresis
        )
        
        if not best:
            self.logger.error("❌ No viable networks (signal too weak)")
            return False
        
        # Connect
        return self.connect_to_network(best)
    
    def disconnect(self):
        """Disconnect from current network"""
        if self.recon.interface:
            self._run_nmcli(["dev", "disconnect", self.recon.interface])
        self.state = ConnectionState.DISCONNECTED
        self.current_network = None

# ═══════════════════════════════════════════════════════════════════
# CAPTIVE PORTAL AUTHENTICATOR
# ═══════════════════════════════════════════════════════════════════

class PortalAuthenticator:
    """Automated captive portal bypass"""
    
    def __init__(self, config: Config, logger: logging.Logger):
        self.config = config
        self.logger = logger
        self.cache_file = config.cache_dir / "auth_cache.json"
    
    def _is_cached(self) -> bool:
        """Check authentication cache"""
        try:
            if not self.cache_file.exists():
                return False
            
            cache = json.loads(self.cache_file.read_text())
            last_auth = datetime.fromisoformat(cache.get("timestamp", ""))
            
            # Cache valid for 4 hours
            return datetime.now() - last_auth < timedelta(hours=4)
        except Exception:
            return False
    
    def _cache_auth(self):
        """Cache successful authentication"""
        cache = {"timestamp": datetime.now().isoformat()}
        self.cache_file.write_text(json.dumps(cache))
    
    async def authenticate(self, portal_url: str, username: str, password: str) -> bool:
        """Authenticate with captive portal"""
        
        if not SELENIUM_AVAILABLE:
            self.logger.error("❌ Selenium not available")
            return False
        
        if self._is_cached():
            self.logger.info("✅ Using cached authentication")
            return True
        
        driver = None
        
        for attempt in range(1, self.config.max_retries + 1):
            try:
                # Try Chrome first
                try:
                    options = StealthTools.get_stealth_chrome_options()
                    driver = webdriver.Chrome(options=options)
                except Exception:
                    # Fallback to Firefox
                    try:
                        options = StealthTools.get_stealth_firefox_options()
                        driver = webdriver.Firefox(options=options)
                    except Exception:
                        self.logger.error("❌ No browser driver available")
                        return False
                
                driver.set_page_load_timeout(self.config.portal_timeout)
                
                # Anti-detection
                driver.execute_script("""
                    Object.defineProperty(navigator, 'webdriver', {get: () => undefined});
                    window.navigator.chrome = {runtime: {}};
                """)
                
                self.logger.info(f"🌐 Navigating to portal: {portal_url}")
                driver.get(portal_url)
                
                # Wait for form
                wait = WebDriverWait(driver, 10)
                username_field = wait.until(
                    EC.presence_of_element_located((By.NAME, "username"))
                )
                password_field = driver.find_element(By.NAME, "password")
                submit_btn = driver.find_element(By.NAME, "submit")
                
                # Fill and submit
                username_field.clear()
                username_field.send_keys(username)
                password_field.clear()
                password_field.send_keys(password)
                submit_btn.click()
                
                # Wait for result
                await asyncio.sleep(5)
                
                # Check success
                page_source = driver.page_source.lower()
                success_indicators = [
                    "success", "logged in", "welcome", "authenticated",
                    "dashboard", "logout", "access granted"
                ]
                
                if any(ind in page_source for ind in success_indicators):
                    self._cache_auth()
                    self.logger.info("✅ Portal authentication successful")
                    return True
                
            except (TimeoutException, WebDriverException) as e:
                delay = self.config.retry_delay * (2 ** (attempt - 1))
                self.logger.warning(f"⚠️  Attempt {attempt}/{self.config.max_retries} failed: {str(e)[:100]}")
                
                if attempt < self.config.max_retries:
                    await asyncio.sleep(delay)
            
            finally:
                if driver:
                    driver.quit()
        
        return False

# ═══════════════════════════════════════════════════════════════════
# MAIN ORCHESTRATOR
# ═══════════════════════════════════════════════════════════════════

class ShadowWiFiArsenal:
    """Main orchestration engine"""
    
    def __init__(self, config: Config):
        self.config = config
        self.logger = self._setup_logging()
        self.credentials = SecureCredentials()
        self.recon = WiFiRecon(self.logger, debug=config.debug_mode)
        self.connection_mgr = ConnectionManager(config, self.recon, self.logger)
        self.authenticator = PortalAuthenticator(config, self.logger)
    
    def _setup_logging(self) -> logging.Logger:
        """Configure logging"""
        logger = logging.getLogger("shadow_wifi")
        logger.setLevel(logging.DEBUG if self.config.debug_mode else logging.INFO)
        
        if not self.config.silent_mode:
            # File handler
            handler = RotatingFileHandler(
                self.config.log_dir / "shadow_wifi.log",
                maxBytes=2_000_000,
                backupCount=3
            )
            handler.setFormatter(logging.Formatter(
                "%(asctime)s - %(levelname)s - %(message)s"
            ))
            logger.addHandler(handler)
            
            # Console
            console = logging.StreamHandler()
            console.setLevel(logging.INFO)
            console.setFormatter(logging.Formatter("%(message)s"))
            logger.addHandler(console)
        
        return logger
    
    async def execute(self) -> bool:
        """Main execution flow"""
        async with aiohttp.ClientSession() as session:
            # Check current connectivity
            if await NetworkTools.check_internet(session):
                self.logger.info("✅ Already connected to internet")
                return True
            
            # Connect to best network
            if not self.connection_mgr.auto_connect_best():
                self.logger.error("❌ Failed to connect to any network")
                return False
            
            await asyncio.sleep(3)  # Stabilize
            
            # Detect captive portal
            is_captive, portal_url = await NetworkTools.detect_captive_portal(session)
            
            if not is_captive:
                self.logger.info("✅ Direct internet access")
                return True
            
            # Use configured portal URL if detection failed
            if not portal_url:
                portal_url = self.config.portal_url
            
            self.logger.info(f"🔐 Captive portal detected: {portal_url}")
            
            # Authenticate
            success = await self.authenticator.authenticate(
                portal_url,
                self.config.username,
                self.config.password
            )
            
            if success and await NetworkTools.check_internet(session):
                self.logger.info("🎯 AUTHENTICATED SUCCESSFULLY!")
                return True
            
            self.logger.error("❌ Authentication failed")
            return False

# ═══════════════════════════════════════════════════════════════════
# MAIN ENTRY POINT
# ═══════════════════════════════════════════════════════════════════

async def main():
    """Main entry point"""
    
    print("""
╔═══════════════════════════════════════════════════════════════════╗
║                WiFi RECON & AUTO-CONNECT ARSENAL                  ║
║            Developed by Bhanu GUragain (Shadow Junior)            ║
╚═══════════════════════════════════════════════════════════════════╝
""")
    
    # Load credentials
    creds = SecureCredentials()
    username, password = creds.load_credentials()
    
    if not username or not password:
        print("🔐 First run - storing credentials securely")
        username = input("Username: ").strip() or "softwarica"
        password = input("Password: ").strip() or "coventry2019"
        creds.store_credentials(username, password)
        print("✅ Credentials encrypted and stored\n")
    
    # Configuration
    config = Config(
        wifi_patterns=[
            "STWCU_LR-*",   # Matches: STWCU_LR-1, STWCU_LR-7, STWCU_LR-10, etc.
            "STWCU_ICR-*",  # Matches: STWCU_ICR-1, STWCU_ICR-2, etc.
        ],
        portal_url="http://gateway.example.com/loginpages/", 
        username=username,
        password=password,
        
        # Advanced configuration
        stealth_mode=True,
        randomize_mac=False,
        silent_mode=False,
        debug_mode=True,  # Enable for detailed debugging
        health_check_interval=300,
        min_signal_strength=30,
        signal_hysteresis=10,
    )
    
    # Execute
    arsenal = ShadowWiFiArsenal(config)
    
    print("🔍 Scanning for networks...")
    success = await arsenal.execute()
    
    if success:
        print("\n✅ MISSION ACCOMPLISHED - Connected and authenticated")
        if arsenal.connection_mgr.current_network:
            print(f"📡 Network: {arsenal.connection_mgr.current_network.ssid}")
            print(f"💪 Signal: {arsenal.connection_mgr.current_network.signal}%")
    else:
        print("\n❌ MISSION FAILED - Could not establish connection")
        sys.exit(1)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user - Shadow out")
        sys.exit(0)
    except Exception as e:
        print(f"\n💥 Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
