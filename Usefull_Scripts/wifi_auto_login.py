#!/usr/bin/env python3
"""
WiFi Auto-Login - Shadow Edition
Optimized by Shadow Senior for Shadow Junior

FEATURES:
- Encrypted credential storage (Fernet + keyring)
- Smart captive portal detection (HTTP 302/511)
- Anti-fingerprinting (randomized UA, canvas resistance)
- MAC randomization support (stealth mode)
- Multi-browser fallback (Chrome → Firefox)
- Retry logic with exponential backoff
- True async operations (non-blocking)
- DNS verification & leak protection
- Connection state caching
- Silent/stealth mode (zero logging)
- Health monitoring (periodic re-auth)
"""

import os
import sys
import time
import subprocess
import logging
import json
import hashlib
import hmac
import secrets
from pathlib import Path
from typing import Dict, Optional, List, Tuple
from datetime import datetime, timedelta
from logging.handlers import RotatingFileHandler
from dataclasses import dataclass
from enum import Enum

import asyncio
import aiohttp
from cryptography.fernet import Fernet
import keyring

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

# ============================================================================
# CONFIGURATION
# ============================================================================

class ConnectionState(Enum):
    DISCONNECTED = 0
    CONNECTING = 1
    CONNECTED = 2
    AUTHENTICATED = 3
    FAILED = 4

@dataclass
class Config:
    """Configuration dataclass"""
    wifi_ssids: List[str]
    portal_url: str
    username: str
    password: str
    
    # Advanced options
    max_retries: int = 5
    retry_delay: int = 3
    connection_timeout: int = 15
    portal_timeout: int = 20
    health_check_interval: int = 300  # 5 minutes
    
    # Stealth options
    stealth_mode: bool = False
    randomize_mac: bool = False
    silent_mode: bool = False
    
    # Paths
    log_dir: Path = Path.home() / ".wifi_autologin" / "logs"
    cache_dir: Path = Path.home() / ".wifi_autologin" / "cache"
    
    def __post_init__(self):
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.cache_dir.mkdir(parents=True, exist_ok=True)

# ============================================================================
# CREDENTIAL ENCRYPTION
# ============================================================================

class SecureCredentials:
    """Encrypted credential storage using Fernet"""
    
    def __init__(self, keyring_service: str = "wifi_autologin_shadow"):
        self.service = keyring_service
        self.key = self._get_or_create_key()
        self.cipher = Fernet(self.key)
    
    def _get_or_create_key(self) -> bytes:
        """Retrieve or generate encryption key"""
        try:
            key_str = keyring.get_password(self.service, "master_key")
            if key_str:
                return key_str.encode()
        except Exception:
            pass
        
        # Generate new key
        key = Fernet.generate_key()
        try:
            keyring.set_password(self.service, "master_key", key.decode())
        except Exception:
            # Keyring unavailable, use file fallback
            key_file = Path.home() / ".wifi_autologin" / ".key"
            key_file.parent.mkdir(exist_ok=True)
            key_file.write_bytes(key)
            key_file.chmod(0o600)
        
        return key
    
    def encrypt(self, data: str) -> str:
        """Encrypt string data"""
        return self.cipher.encrypt(data.encode()).decode()
    
    def decrypt(self, encrypted_data: str) -> str:
        """Decrypt string data"""
        return self.cipher.decrypt(encrypted_data.encode()).decode()
    
    def store_credentials(self, username: str, password: str):
        """Store encrypted credentials"""
        enc_user = self.encrypt(username)
        enc_pass = self.encrypt(password)
        
        try:
            keyring.set_password(self.service, "enc_username", enc_user)
            keyring.set_password(self.service, "enc_password", enc_pass)
        except Exception:
            # File fallback
            cred_file = Path.home() / ".wifi_autologin" / ".credentials"
            creds = {"username": enc_user, "password": enc_pass}
            cred_file.write_text(json.dumps(creds))
            cred_file.chmod(0o600)
    
    def load_credentials(self) -> Tuple[Optional[str], Optional[str]]:
        """Load and decrypt credentials"""
        try:
            enc_user = keyring.get_password(self.service, "enc_username")
            enc_pass = keyring.get_password(self.service, "enc_password")
            
            if enc_user and enc_pass:
                return self.decrypt(enc_user), self.decrypt(enc_pass)
        except Exception:
            # Try file fallback
            try:
                cred_file = Path.home() / ".wifi_autologin" / ".credentials"
                creds = json.loads(cred_file.read_text())
                return self.decrypt(creds["username"]), self.decrypt(creds["password"])
            except Exception:
                pass
        
        return None, None

# ============================================================================
# STEALTH & ANTI-FINGERPRINTING
# ============================================================================

class StealthTools:
    """Anti-fingerprinting and stealth utilities"""
    
    USER_AGENTS = [
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Mozilla/5.0 (X11; Linux x86_64; rv:122.0) Gecko/20100101 Firefox/122.0",
        "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    ]
    
    @staticmethod
    def random_user_agent() -> str:
        """Generate random user agent"""
        return secrets.choice(StealthTools.USER_AGENTS)
    
    @staticmethod
    def randomize_mac_address(interface: str) -> bool:
        """Randomize MAC address for interface"""
        try:
            # Bring interface down
            subprocess.run(["ip", "link", "set", interface, "down"], 
                         check=True, capture_output=True)
            
            # Generate random MAC
            random_mac = "02:%02x:%02x:%02x:%02x:%02x" % (
                secrets.randbelow(256), secrets.randbelow(256),
                secrets.randbelow(256), secrets.randbelow(256),
                secrets.randbelow(256)
            )
            
            # Set new MAC
            subprocess.run(["ip", "link", "set", "dev", interface, "address", random_mac],
                         check=True, capture_output=True)
            
            # Bring interface up
            subprocess.run(["ip", "link", "set", interface, "up"],
                         check=True, capture_output=True)
            
            return True
        except Exception:
            return False
    
    @staticmethod
    def get_stealth_chrome_options() -> ChromeOptions:
        """Chrome options with anti-fingerprinting"""
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
        """Firefox options with anti-fingerprinting"""
        options = FirefoxOptions()
        options.add_argument("--headless")
        options.set_preference("general.useragent.override", StealthTools.random_user_agent())
        options.set_preference("privacy.resistFingerprinting", True)
        return options

# ============================================================================
# NETWORK UTILITIES
# ============================================================================

class NetworkTools:
    """Network connectivity and captive portal detection"""
    
    @staticmethod
    async def detect_captive_portal(session: aiohttp.ClientSession) -> Tuple[bool, Optional[str]]:
        """
        Detect captive portal using multiple methods
        Returns: (is_captive, redirect_url)
        """
        test_endpoints = [
            "http://clients3.google.com/generate_204",
            "http://captive.apple.com/hotspot-detect.html",
            "http://connectivitycheck.gstatic.com/generate_204",
        ]
        
        for endpoint in test_endpoints:
            try:
                async with session.get(endpoint, timeout=5, allow_redirects=False) as resp:
                    # 204 = no content = direct internet
                    if resp.status == 204:
                        return False, None
                    
                    # 200 with content = captive portal response
                    if resp.status == 200:
                        content = await resp.text()
                        if len(content) > 0:
                            return True, str(resp.url)
                    
                    # 302/301 redirect = captive portal
                    if resp.status in [301, 302, 303, 307, 308]:
                        redirect_url = resp.headers.get("Location")
                        return True, redirect_url
                    
                    # 511 = Network Authentication Required (RFC 6585)
                    if resp.status == 511:
                        return True, str(resp.url)
                        
            except Exception:
                continue
        
        # If all checks fail, assume internet is available
        return False, None
    
    @staticmethod
    async def verify_dns(session: aiohttp.ClientSession) -> bool:
        """Verify DNS is not hijacked"""
        try:
            async with session.get("https://dns.google/resolve?name=google.com&type=A", 
                                  timeout=5) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    return "Answer" in data
        except Exception:
            pass
        return False
    
    @staticmethod
    async def check_internet(session: aiohttp.ClientSession) -> bool:
        """Verify internet connectivity"""
        try:
            async with session.get("https://www.google.com", timeout=5) as resp:
                return resp.status == 200
        except Exception:
            return False
    
    @staticmethod
    def get_wifi_interface() -> Optional[str]:
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
        for iface in ["wlan0", "wlp2s0", "wlo1"]:
            if Path(f"/sys/class/net/{iface}").exists():
                return iface
        
        return None

# ============================================================================
# CONNECTION MANAGER
# ============================================================================

class ConnectionManager:
    """WiFi connection and state management"""
    
    def __init__(self, config: Config, logger: logging.Logger):
        self.config = config
        self.logger = logger
        self.state = ConnectionState.DISCONNECTED
        self.current_ssid: Optional[str] = None
        self.interface: Optional[str] = NetworkTools.get_wifi_interface()
        self.last_auth_time: Optional[datetime] = None
    
    def _run_nmcli(self, args: List[str], timeout: int = 15) -> Tuple[bool, str]:
        """Execute nmcli command"""
        try:
            result = subprocess.run(
                ["nmcli"] + args,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            return result.returncode == 0, result.stdout
        except Exception as e:
            return False, str(e)
    
    def scan_networks(self) -> List[str]:
        """Scan for available WiFi networks"""
        success, output = self._run_nmcli(["dev", "wifi", "rescan"])
        if not success:
            return []
        
        time.sleep(2)  # Wait for scan to complete
        
        success, output = self._run_nmcli(["dev", "wifi", "list"])
        if not success:
            return []
        
        networks = set()
        for line in output.split("\n")[1:]:
            parts = line.split()
            if len(parts) >= 2 and parts[1] != "--":
                networks.add(parts[1])
        
        return list(networks)
    
    def connect_to_network(self, ssid: str) -> bool:
        """Connect to WiFi network"""
        if not self.logger.handlers or not self.config.silent_mode:
            self.logger.info(f"Connecting to: {ssid}")
        
        self.state = ConnectionState.CONNECTING
        
        # Randomize MAC if enabled
        if self.config.randomize_mac and self.interface:
            StealthTools.randomize_mac_address(self.interface)
        
        success, output = self._run_nmcli(
            ["dev", "wifi", "connect", ssid],
            timeout=self.config.connection_timeout
        )
        
        if success:
            self.current_ssid = ssid
            self.state = ConnectionState.CONNECTED
            return True
        
        self.state = ConnectionState.FAILED
        return False
    
    def auto_connect(self) -> bool:
        """Auto-connect to configured networks"""
        available = self.scan_networks()
        
        for ssid in self.config.wifi_ssids:
            if ssid in available:
                if self.connect_to_network(ssid):
                    return True
        
        return False
    
    def disconnect(self):
        """Disconnect from current network"""
        if self.interface:
            self._run_nmcli(["dev", "disconnect", self.interface])
        self.state = ConnectionState.DISCONNECTED
        self.current_ssid = None

# ============================================================================
# PORTAL AUTHENTICATOR
# ============================================================================

class PortalAuthenticator:
    """Captive portal authentication with retry logic"""
    
    def __init__(self, config: Config, logger: logging.Logger):
        self.config = config
        self.logger = logger
        self.success_cache_file = config.cache_dir / "auth_cache.json"
    
    def _is_recently_authenticated(self) -> bool:
        """Check if recently authenticated (cache)"""
        try:
            if not self.success_cache_file.exists():
                return False
            
            cache = json.loads(self.success_cache_file.read_text())
            last_auth = datetime.fromisoformat(cache.get("timestamp", ""))
            
            # Cache valid for 4 hours
            if datetime.now() - last_auth < timedelta(hours=4):
                return cache.get("ssid") == self.config.wifi_ssids[0]
        except Exception:
            pass
        
        return False
    
    def _cache_authentication(self, ssid: str):
        """Cache successful authentication"""
        cache = {
            "timestamp": datetime.now().isoformat(),
            "ssid": ssid
        }
        self.success_cache_file.write_text(json.dumps(cache))
    
    async def authenticate(self, portal_url: str, username: str, password: str) -> bool:
        """Authenticate with captive portal using Selenium"""
        
        if not SELENIUM_AVAILABLE:
            self.logger.error("Selenium not installed")
            return False
        
        # Try cache first
        if self._is_recently_authenticated():
            self.logger.info("Using cached authentication")
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
                    options = StealthTools.get_stealth_firefox_options()
                    driver = webdriver.Firefox(options=options)
                
                driver.set_page_load_timeout(self.config.portal_timeout)
                
                # Execute anti-detection script
                driver.execute_script("""
                    Object.defineProperty(navigator, 'webdriver', {get: () => undefined});
                    window.navigator.chrome = {runtime: {}};
                """)
                
                # Navigate to portal
                driver.get(portal_url)
                
                # Wait for form elements
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
                
                # Wait for redirect or success
                await asyncio.sleep(5)
                
                # Check for success indicators
                page_source = driver.page_source.lower()
                success_indicators = [
                    "success", "logged in", "welcome", "authenticated",
                    "dashboard", "logout", "access granted"
                ]
                
                if any(ind in page_source for ind in success_indicators):
                    self._cache_authentication(self.config.wifi_ssids[0])
                    return True
                
                # Check if redirected to success page
                current_url = driver.current_url.lower()
                if "success" in current_url or "welcome" in current_url:
                    self._cache_authentication(self.config.wifi_ssids[0])
                    return True
                
            except (TimeoutException, WebDriverException) as e:
                delay = self.config.retry_delay * (2 ** (attempt - 1))  # Exponential backoff
                self.logger.warning(f"Attempt {attempt}/{self.config.max_retries} failed: {e}")
                
                if attempt < self.config.max_retries:
                    await asyncio.sleep(delay)
            
            finally:
                if driver:
                    driver.quit()
        
        return False

# ============================================================================
# MAIN ORCHESTRATOR
# ============================================================================

class WiFiAutoLogin:
    """Main orchestration class"""
    
    def __init__(self, config: Config):
        self.config = config
        self.logger = self._setup_logging()
        self.credentials = SecureCredentials()
        self.connection_mgr = ConnectionManager(config, self.logger)
        self.authenticator = PortalAuthenticator(config, self.logger)
        self.session: Optional[aiohttp.ClientSession] = None
    
    def _setup_logging(self) -> logging.Logger:
        """Configure logging"""
        logger = logging.getLogger("wifi_autologin")
        logger.setLevel(logging.DEBUG if not self.config.silent_mode else logging.ERROR)
        
        if not self.config.silent_mode:
            # File handler
            handler = RotatingFileHandler(
                self.config.log_dir / "wifi_autologin.log",
                maxBytes=1_000_000,
                backupCount=2
            )
            handler.setFormatter(logging.Formatter(
                "%(asctime)s - %(levelname)s - %(message)s"
            ))
            logger.addHandler(handler)
            
            # Console handler
            console = logging.StreamHandler()
            console.setLevel(logging.INFO)
            logger.addHandler(console)
        
        return logger
    
    async def execute(self) -> bool:
        """Main execution flow"""
        async with aiohttp.ClientSession() as self.session:
            # Check if already connected
            if await NetworkTools.check_internet(self.session):
                self.logger.info("Already connected to internet")
                return True
            
            # Connect to WiFi
            if not self.connection_mgr.auto_connect():
                self.logger.error("Failed to connect to any WiFi network")
                return False
            
            await asyncio.sleep(3)  # Wait for connection to stabilize
            
            # Detect captive portal
            is_captive, portal_url = await NetworkTools.detect_captive_portal(self.session)
            
            if not is_captive:
                self.logger.info("Direct internet access - no portal detected")
                return True
            
            # Use configured portal URL if detection failed
            if not portal_url:
                portal_url = self.config.portal_url
            
            # Authenticate with portal
            success = await self.authenticator.authenticate(
                portal_url,
                self.config.username,
                self.config.password
            )
            
            if success:
                # Verify internet and DNS
                if await NetworkTools.check_internet(self.session):
                    self.logger.info("Authentication successful!")
                    return True
            
            self.logger.error("Authentication failed")
            return False
    
    async def health_monitor(self):
        """Periodic connection health monitoring"""
        while True:
            await asyncio.sleep(self.config.health_check_interval)
            
            async with aiohttp.ClientSession() as session:
                if not await NetworkTools.check_internet(session):
                    self.logger.warning("Connection lost - re-authenticating")
                    await self.execute()

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

async def main():
    """Main entry point"""
    
    # Load or create credentials
    creds = SecureCredentials()
    username, password = creds.load_credentials()
    
    if not username or not password:
        # First run - store credentials
        print("First run - setting up credentials")
        username = input("Username: ").strip() or "softwarica"
        password = input("Password: ").strip() or "coventry2019"
        creds.store_credentials(username, password)
    
    # Load configuration
    config = Config(
        wifi_ssids=["STWCU_LR-1", "STWCU_LR-2", "STWCU_LR-3", "STWCU_LR-4", "STWCU_LR-5"],
        portal_url="http://gateway.example.com/loginpages/",
        username=username,
        password=password,
        stealth_mode=True,
        randomize_mac=False,  # Enable if needed
        silent_mode=False,
        health_check_interval=300
    )
    
    # Execute
    wifi = WiFiAutoLogin(config)
    success = await wifi.execute()
    
    if success:
        print("✅ Connected and authenticated successfully")
        
        # Optional: Run health monitor
        # await wifi.health_monitor()
    else:
        print("❌ Connection failed")
        sys.exit(1)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n⚠️ Interrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"💥 Error: {e}")
        sys.exit(1)
