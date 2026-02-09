# Docker on Windows — Installation & Docker Compose Guide

This guide explains how to install **Docker Desktop on Windows** and how to run:

```bash
docker compose up --build
```

---

## 1. System Requirements

- **Windows 10 / 11 (64‑bit)**
  - Pro / Enterprise / Education → recommended
  - Home → supported via **WSL2**
- **Virtualization enabled** in BIOS/UEFI
- Administrator privileges

---

## 2. Install Docker Desktop

### Step 1 — Download

Download Docker Desktop for Windows:

https://www.docker.com/products/docker-desktop/

### Step 2 — Install

1. Run `Docker Desktop Installer.exe`
2. When prompted:
   - Enable **Use WSL 2 instead of Hyper‑V** (recommended)
3. Complete installation
4. Reboot if requested

### Step 3 — Verify Docker Settings

1. Open **Docker Desktop**
2. Go to **Settings → General**
   - Ensure **Use the WSL 2 based engine** is enabled
3. Go to **Settings → Resources → WSL Integration**
   - Enable integration for your Linux distro (e.g. Ubuntu)

---

## 3. Install WSL2 (If Not Installed)

Run in **PowerShell (Admin)**:

```powershell
wsl --install
```

Reboot when finished.

Verify:

```powershell
wsl --status
```

---

## 4. Verify Docker Installation

Open **PowerShell** or **Windows Terminal**:

```powershell
docker --version
docker compose version
```

Test the engine:

```powershell
docker run hello-world
```

You should see a success message.

---

## 5. Run `docker compose up --build`

### Step 1 — Go to Project Directory

Your directory must contain a `docker-compose.yml` or `compose.yml` file.

```powershell
cd C:\path\to\your\project
```

### Step 2 — Build and Start Containers

```powershell
docker compose up --build
```

What this does:
- Builds images from Dockerfiles
- Starts all services
- Streams logs to the terminal

### Step 3 — Run in Background (Optional)

```powershell
docker compose up --build -d
```

---

## 6. Common Docker Compose Commands

Stop containers:

```powershell
docker compose down
```

Rebuild images only:

```powershell
docker compose build
```

List running containers:

```powershell
docker ps
```

View logs:

```powershell
docker compose logs -f
```

---

## 7. Common Windows Issues

### Virtualization Disabled

Enable **Intel VT‑x / AMD‑V** in BIOS.

Enable Windows feature:

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Reboot after enabling.

---

### `docker compose` Command Not Found

- Update Docker Desktop to the latest version
- Restart your terminal
- Use `docker compose` (not `docker-compose`)

---

### Volume / File Permission Issues

Best practices:
- Prefer working inside **WSL filesystem**:

```
\\wsl$\Ubuntu\home\user\project
```

- Avoid heavy bind mounts from `C:\` when possible

---

## 8. Minimal `docker-compose.yml` Example

```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
```

Run:

```powershell
docker compose up --build
```

---

## Notes

- Docker Desktop must be running before executing Docker commands
- WSL2 backend is strongly recommended for performance
- This setup works well for Rails, Go, Node.js, and most backend stacks

