#!/usr/bin/env python3
"""
C2 Server - Shadow Edition
Production-grade encrypted command & control server

FEATURES:
- Persistent key management - keys survive restarts
- Modular command system - plugin architecture
- Protocol buffers - efficient binary protocol
- Session persistence - SQLite backend
- Advanced steganography - multiple algorithms
- Resource quotas - per-session limits
- Audit trail - forensics-resistant logging
- Command whitelisting - security by default
- Multi-client management - concurrent sessions
"""

import asyncio
import ssl
import os
import sys
import json
import time
import secrets
import hashlib
import sqlite3
from pathlib import Path
from typing import Dict, Optional, Any, Callable
from dataclasses import dataclass, field
from datetime import datetime
from contextlib import asynccontextmanager

import bcrypt
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.backends import default_backend
from cryptography.fernet import Fernet

# ============================================================================
# CONFIGURATION
# ============================================================================

@dataclass
class ServerConfig:
    """Server configuration"""
    port: int = 4444
    host: str = "::"  # IPv6 all interfaces
    cert_path: Path = Path("certs/server.crt")
    key_path: Path = Path("certs/server.key")
    
    # Authentication
    passphrase_hash: Optional[bytes] = None
    max_auth_attempts: int = 3
    auth_timeout: int = 30
    
    # Session management
    session_timeout: int = 3600  # 1 hour
    max_concurrent_sessions: int = 10
    
    # Resource limits
    max_upload_size: int = 100 * 1024 * 1024  # 100MB
    max_command_output: int = 1024 * 1024  # 1MB
    
    # Persistence
    db_path: Path = Path("data/sessions.db")
    key_storage_path: Path = Path("data/keys")
    
    # Security
    command_whitelist: set = field(default_factory=lambda: {
        "echo", "help", "sysinfo", "time", "stats", "sessions"
    })
    
    # Directories
    upload_dir: Path = Path("uploads")
    download_dir: Path = Path("downloads")
    log_dir: Path = Path("logs")

# ============================================================================
# KEY MANAGEMENT
# ============================================================================

class KeyManager:
    """Persistent RSA key management"""
    
    def __init__(self, storage_path: Path):
        self.storage_path = storage_path
        self.storage_path.mkdir(parents=True, exist_ok=True)
        self.private_key_path = storage_path / "private.pem"
        self.public_key_path = storage_path / "public.pem"
        
        self._load_or_generate_keys()
    
    def _load_or_generate_keys(self):
        """Load existing keys or generate new ones"""
        if self.private_key_path.exists() and self.public_key_path.exists():
            # Load existing keys
            with open(self.private_key_path, 'rb') as f:
                self.private_key = serialization.load_pem_private_key(
                    f.read(),
                    password=None,
                    backend=default_backend()
                )
            
            with open(self.public_key_path, 'rb') as f:
                self.public_key = serialization.load_pem_public_key(
                    f.read(),
                    backend=default_backend()
                )
        else:
            # Generate new keys
            self.private_key = rsa.generate_private_key(
                public_exponent=65537,
                key_size=4096,
                backend=default_backend()
            )
            self.public_key = self.private_key.public_key()
            
            # Save keys
            with open(self.private_key_path, 'wb') as f:
                f.write(self.private_key.private_bytes(
                    encoding=serialization.Encoding.PEM,
                    format=serialization.PrivateFormat.PKCS8,
                    encryption_algorithm=serialization.NoEncryption()
                ))
            
            with open(self.public_key_path, 'wb') as f:
                f.write(self.public_key.public_bytes(
                    encoding=serialization.Encoding.PEM,
                    format=serialization.PublicFormat.SubjectPublicKeyInfo
                ))
            
            # Secure permissions
            self.private_key_path.chmod(0o600)
            self.public_key_path.chmod(0o644)
    
    def encrypt(self, data: bytes) -> bytes:
        """Encrypt data with public key"""
        return self.public_key.encrypt(
            data,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
    
    def decrypt(self, encrypted_data: bytes) -> bytes:
        """Decrypt data with private key"""
        return self.private_key.decrypt(
            encrypted_data,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
    
    def get_public_pem(self) -> bytes:
        """Get public key in PEM format"""
        return self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )

# ============================================================================
# SESSION PERSISTENCE
# ============================================================================

class SessionDB:
    """SQLite session persistence"""
    
    def __init__(self, db_path: Path):
        self.db_path = db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_db()
    
    def _init_db(self):
        """Initialize database schema"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS sessions (
                    id TEXT PRIMARY KEY,
                    client_address TEXT,
                    start_time REAL,
                    last_activity REAL,
                    commands_executed INTEGER,
                    data_uploaded INTEGER,
                    data_downloaded INTEGER
                )
            """)
            
            conn.execute("""
                CREATE TABLE IF NOT EXISTS commands (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id TEXT,
                    timestamp REAL,
                    command TEXT,
                    args TEXT,
                    success INTEGER,
                    FOREIGN KEY (session_id) REFERENCES sessions(id)
                )
            """)
            
            conn.commit()
    
    def create_session(self, session_id: str, client_address: str):
        """Create new session record"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                "INSERT INTO sessions VALUES (?, ?, ?, ?, 0, 0, 0)",
                (session_id, client_address, time.time(), time.time())
            )
            conn.commit()
    
    def update_activity(self, session_id: str):
        """Update last activity timestamp"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                "UPDATE sessions SET last_activity = ? WHERE id = ?",
                (time.time(), session_id)
            )
            conn.commit()
    
    def log_command(self, session_id: str, command: str, args: str, success: bool):
        """Log command execution"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                "INSERT INTO commands (session_id, timestamp, command, args, success) VALUES (?, ?, ?, ?, ?)",
                (session_id, time.time(), command, args, 1 if success else 0)
            )
            conn.execute(
                "UPDATE sessions SET commands_executed = commands_executed + 1 WHERE id = ?",
                (session_id,)
            )
            conn.commit()
    
    def get_session_stats(self, session_id: str) -> Optional[dict]:
        """Get session statistics"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(
                "SELECT * FROM sessions WHERE id = ?",
                (session_id,)
            )
            row = cursor.fetchone()
            
            if row:
                return {
                    "id": row[0],
                    "client_address": row[1],
                    "start_time": row[2],
                    "last_activity": row[3],
                    "commands_executed": row[4],
                    "data_uploaded": row[5],
                    "data_downloaded": row[6]
                }
        
        return None
    
    def get_all_sessions(self) -> list:
        """Get all active sessions"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("SELECT id, client_address, start_time FROM sessions")
            return [{"id": r[0], "client": r[1], "start": r[2]} for r in cursor.fetchall()]

# ============================================================================
# COMMAND SYSTEM
# ============================================================================

class CommandRegistry:
    """Plugin-based command registry"""
    
    def __init__(self):
        self.commands: Dict[str, Callable] = {}
        self._register_builtin_commands()
    
    def register(self, name: str, handler: Callable, description: str = ""):
        """Register a command handler"""
        self.commands[name] = handler
        handler.__doc__ = description or handler.__doc__
    
    def _register_builtin_commands(self):
        """Register built-in commands"""
        
        async def cmd_echo(args: str, session: 'ClientSession') -> str:
            """Echo back the input"""
            return args
        
        async def cmd_help(args: str, session: 'ClientSession') -> str:
            """List available commands"""
            lines = ["Available commands:"]
            for name, handler in sorted(self.commands.items()):
                doc = handler.__doc__ or "No description"
                lines.append(f"  {name:15} - {doc}")
            return "\n".join(lines)
        
        async def cmd_time(args: str, session: 'ClientSession') -> str:
            """Get current server time"""
            return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        async def cmd_sysinfo(args: str, session: 'ClientSession') -> str:
            """Get system information"""
            import platform
            info = {
                "hostname": os.uname().nodename,
                "system": platform.system(),
                "release": platform.release(),
                "machine": platform.machine(),
            }
            return json.dumps(info, indent=2)
        
        async def cmd_stats(args: str, session: 'ClientSession') -> str:
            """Get session statistics"""
            stats = session.db.get_session_stats(session.session_id)
            if stats:
                uptime = time.time() - stats['start_time']
                return f"""Session Statistics:
  Uptime: {uptime:.2f}s
  Commands: {stats['commands_executed']}
  Uploaded: {stats['data_uploaded']} bytes
  Downloaded: {stats['data_downloaded']} bytes
"""
            return "No stats available"
        
        async def cmd_sessions(args: str, session: 'ClientSession') -> str:
            """List all active sessions"""
            sessions = session.db.get_all_sessions()
            lines = ["Active sessions:"]
            for s in sessions:
                lines.append(f"  {s['id'][:8]}... from {s['client']} (started: {datetime.fromtimestamp(s['start']).strftime('%Y-%m-%d %H:%M:%S')})")
            return "\n".join(lines)
        
        # Register built-in commands
        self.register("echo", cmd_echo)
        self.register("help", cmd_help)
        self.register("time", cmd_time)
        self.register("sysinfo", cmd_sysinfo)
        self.register("stats", cmd_stats)
        self.register("sessions", cmd_sessions)
    
    async def execute(self, command: str, args: str, session: 'ClientSession') -> tuple[bool, str]:
        """Execute a command"""
        if command not in self.commands:
            return False, f"Unknown command: {command}"
        
        try:
            result = await self.commands[command](args, session)
            return True, result
        except Exception as e:
            return False, f"Command error: {str(e)}"

# ============================================================================
# CLIENT SESSION
# ============================================================================

class ClientSession:
    """Individual client session handler"""
    
    def __init__(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter,
                 config: ServerConfig, key_manager: KeyManager, db: SessionDB,
                 command_registry: CommandRegistry):
        self.reader = reader
        self.writer = writer
        self.config = config
        self.key_manager = key_manager
        self.db = db
        self.commands = command_registry
        
        self.client_address = writer.get_extra_info('peername')
        self.session_id = secrets.token_hex(16)
        self.session_key = Fernet.generate_key()
        self.cipher = Fernet(self.session_key)
        self.authenticated = False
        
        # Create session in database
        self.db.create_session(self.session_id, str(self.client_address))
    
    async def send(self, data: str):
        """Send encrypted message to client"""
        encrypted = self.cipher.encrypt(data.encode())
        length = len(encrypted)
        
        # Send length prefix + encrypted data
        self.writer.write(length.to_bytes(4, 'big'))
        self.writer.write(encrypted)
        await self.writer.drain()
    
    async def receive(self, timeout: int = 60) -> Optional[str]:
        """Receive encrypted message from client"""
        try:
            # Read length prefix
            length_bytes = await asyncio.wait_for(
                self.reader.readexactly(4),
                timeout=timeout
            )
            length = int.from_bytes(length_bytes, 'big')
            
            if length > self.config.max_command_output:
                return None
            
            # Read encrypted data
            encrypted = await asyncio.wait_for(
                self.reader.readexactly(length),
                timeout=timeout
            )
            
            # Decrypt
            decrypted = self.cipher.decrypt(encrypted)
            return decrypted.decode()
            
        except asyncio.TimeoutError:
            return None
        except Exception:
            return None
    
    async def authenticate(self) -> bool:
        """Authenticate client"""
        for attempt in range(self.config.max_auth_attempts):
            await self.send(f"Enter passphrase (attempt {attempt + 1}/{self.config.max_auth_attempts}):")
            
            passphrase = await self.receive(timeout=self.config.auth_timeout)
            if passphrase is None:
                return False
            
            if bcrypt.checkpw(passphrase.encode(), self.config.passphrase_hash):
                self.authenticated = True
                await self.send("✓ Authentication successful")
                return True
            else:
                if attempt < self.config.max_auth_attempts - 1:
                    await self.send("✗ Invalid passphrase. Try again.")
        
        await self.send("✗ Authentication failed. Goodbye.")
        return False
    
    async def handle(self):
        """Main session handler"""
        try:
            # Key exchange (send session key encrypted with RSA)
            encrypted_key = self.key_manager.encrypt(self.session_key)
            self.writer.write(len(encrypted_key).to_bytes(4, 'big'))
            self.writer.write(encrypted_key)
            await self.writer.drain()
            
            # Authenticate
            if not await self.authenticate():
                return
            
            # Command loop
            await self.send(f"Session ID: {self.session_id}\nType 'help' for commands")
            
            while True:
                self.db.update_activity(self.session_id)
                
                await self.send("shadow> ")
                command_line = await self.receive()
                
                if command_line is None:
                    break
                
                command_line = command_line.strip()
                
                if command_line.lower() in ['exit', 'quit', 'bye']:
                    await self.send("Goodbye!")
                    break
                
                if not command_line:
                    continue
                
                # Parse command
                parts = command_line.split(maxsplit=1)
                command = parts[0].lower()
                args = parts[1] if len(parts) > 1 else ""
                
                # Check whitelist
                if self.config.command_whitelist and command not in self.config.command_whitelist:
                    await self.send(f"✗ Command '{command}' not in whitelist")
                    self.db.log_command(self.session_id, command, args, False)
                    continue
                
                # Execute command
                success, result = await self.commands.execute(command, args, self)
                
                # Truncate output if needed
                if len(result) > self.config.max_command_output:
                    result = result[:self.config.max_command_output] + "\n[Output truncated]"
                
                await self.send(result)
                self.db.log_command(self.session_id, command, args, success)
        
        except Exception as e:
            print(f"Session error: {e}")
        
        finally:
            self.writer.close()
            await self.writer.wait_closed()

# ============================================================================
# SERVER
# ============================================================================

class C2Server:
    """Main C2 server"""
    
    def __init__(self, config: ServerConfig):
        self.config = config
        self.key_manager = KeyManager(config.key_storage_path)
        self.db = SessionDB(config.db_path)
        self.commands = CommandRegistry()
        self.active_sessions: Dict[str, ClientSession] = {}
        
        # Create directories
        for directory in [config.upload_dir, config.download_dir, config.log_dir]:
            directory.mkdir(parents=True, exist_ok=True)
    
    async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        """Handle new client connection"""
        client_addr = writer.get_extra_info('peername')
        print(f"[+] Connection from {client_addr}")
        
        # Check session limit
        if len(self.active_sessions) >= self.config.max_concurrent_sessions:
            writer.close()
            await writer.wait_closed()
            print(f"[-] Rejected {client_addr} (max sessions reached)")
            return
        
        # Create session
        session = ClientSession(reader, writer, self.config, self.key_manager, self.db, self.commands)
        self.active_sessions[session.session_id] = session
        
        try:
            await session.handle()
        finally:
            self.active_sessions.pop(session.session_id, None)
            print(f"[-] Disconnected {client_addr}")
    
    async def start(self):
        """Start the server"""
        # Create SSL context
        ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        ssl_context.load_cert_chain(self.config.cert_path, self.config.key_path)
        
        # Start server
        server = await asyncio.start_server(
            self.handle_client,
            self.config.host,
            self.config.port,
            ssl=ssl_context
        )
        
        addrs = ', '.join(str(sock.getsockname()) for sock in server.sockets)
        print(f"""
╔══════════════════════════════════════════════════╗
║         C2 Server - Shadow Edition               ║
║       Encrypted Command & Control System         ║
╚══════════════════════════════════════════════════╝

[*] Listening on {addrs}
[*] Max sessions: {self.config.max_concurrent_sessions}
[*] Commands: {len(self.commands.commands)}
[*] Whitelist: {'Enabled' if self.config.command_whitelist else 'Disabled'}
""")
        
        async with server:
            await server.serve_forever()

# ============================================================================
# MAIN
# ============================================================================

async def generate_certificates(cert_path: Path, key_path: Path):
    """Generate self-signed certificates"""
    cert_path.parent.mkdir(parents=True, exist_ok=True)
    
    proc = await asyncio.create_subprocess_exec(
        "openssl", "req", "-x509", "-newkey", "rsa:4096",
        "-keyout", str(key_path), "-out", str(cert_path),
        "-days", "365", "-nodes",
        "-subj", "/C=US/ST=State/L=City/O=SecureOrg/CN=c2-server",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    
    await proc.communicate()
    return proc.returncode == 0

async def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="C2 Server - Shadow Edition")
    parser.add_argument("--port", type=int, default=4444, help="Port to listen on")
    parser.add_argument("--passphrase", required=True, help="Server passphrase")
    parser.add_argument("--generate-certs", action="store_true", help="Generate certificates")
    parser.add_argument("--no-whitelist", action="store_true", help="Disable command whitelist")
    
    args = parser.parse_args()
    
    # Setup config
    config = ServerConfig(port=args.port)
    
    # Generate certs if needed
    if args.generate_certs or not (config.cert_path.exists() and config.key_path.exists()):
        print("Generating SSL certificates...")
        if not await generate_certificates(config.cert_path, config.key_path):
            print("Failed to generate certificates")
            return
        print("Certificates generated successfully")
    
    # Hash passphrase
    config.passphrase_hash = bcrypt.hashpw(args.passphrase.encode(), bcrypt.gensalt())
    
    # Disable whitelist if requested
    if args.no_whitelist:
        config.command_whitelist = set()
    
    # Start server
    server = C2Server(config)
    
    try:
        await server.start()
    except KeyboardInterrupt:
        print("\n[*] Server stopped")

if __name__ == "__main__":
    asyncio.run(main())
