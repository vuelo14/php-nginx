# PHP 8.3 + Nginx (Multi-Architecture: ARM64 & AMD64)

Docker image all-in-one yang menggabungkan **PHP 8.3-FPM** dan **Nginx** dalam 1 container, dikelola menggunakan **Supervisor**. Image ini mendukung arsitektur multi-platform (**ARM64** seperti Apple Silicon / Raspberry Pi / AWS Graviton dan **AMD64/x86_64** untuk PC/Server standar), serta otomatis dibuild dan dipublish ke **GitHub Container Registry (GHCR)** setiap kali Anda melakukan `git push` ke GitHub.

---

## 🚀 Fitur Unggulan

- **All-in-One Container**: PHP-FPM dan Nginx berjalan bersamaan dalam satu container menggunakan Supervisor.
- **Dukungan Multi-Arch**: Otomatis dibuild untuk `linux/arm64` dan `linux/amd64` melalui GitHub Actions + QEMU + Buildx.
- **Otomatisasi Penuh (CI/CD)**: Terpicu secara otomatis saat `git push` ke branch `main`/`master` atau saat membuat tag rilis.
- **GitHub Container Registry (GHCR)**: Langsung dipublish ke `ghcr.io` tanpa perlu setup secret token Docker Hub manual.
- **Ekstensi PHP Lengkap**: `pdo_mysql`, `pdo_pgsql`, `pgsql`, `mbstring`, `exif`, `pcntl`, `bcmath`, `gd`, `zip`, `intl`, `opcache`.
- **Runtime Tambahan**: Composer, Node.js, npm, git, curl, unzip, bash.
- **Optimasi Laravel & Livewire**: Buffer FastCGI dan upload limit sudah disesuaikan agar tidak error saat request payload besar.
- **Dynamic Document Root**: Default ke `/var/www/html/public` (Laravel), otomatis fallback ke `/var/www/html` jika folder `public` tidak ada, atau bisa diatur via environment variable `DOCUMENT_ROOT`.

---

## 📁 Struktur Direktori

```text
├── .github/
│   └── workflows/
│       └── docker-build-push.yml   # Workflow GitHub Actions (Build multi-arch & push ke GHCR)
├── docker/
│   ├── entrypoint.sh               # Script entrypoint container
│   ├── nginx/
│   │   └── default.conf            # Konfigurasi virtual host Nginx
│   ├── php/
│   │   └── custom.ini              # Konfigurasi PHP (memory, upload limit, opcache)
│   └── supervisor/
│       └── supervisord.conf        # Supervisor untuk menjalankan PHP-FPM & Nginx
├── public/
│   └── index.php                   # Halaman uji coba / info sistem
├── .dockerignore                   # File/folder yang diabaikan saat build docker
├── Dockerfile                      # Spesifikasi Dockerfile multi-arch
├── default.conf                    # Backup / mount Nginx config
├── docker-compose.yml              # Konfigurasi Docker Compose lokal
└── README.md
```

---

## ⚙️ Persiapan di GitHub (Wajib)

Agar GitHub Actions memiliki izin untuk menyimpan image ke **GitHub Container Registry (GHCR)**:

1. Buka repositori Anda di GitHub.
2. Masuk ke menu **Settings** > **Actions** > **General**.
3. Gulir ke bagian **Workflow permissions**.
4. Pilih **"Read and write permissions"**.
5. Klik **Save**.

> **Catatan**: Workflow ini menggunakan `GITHUB_TOKEN` bawaan GitHub, sehingga Anda **TIDAK PERLU** membuat Personal Access Token (PAT) atau Secret manual.

---

## 🔄 Cara Kerja Otomatisasi (GitHub Actions)

Image akan otomatis dibuild dan dipush ketika:
1. Anda melakukan `git push` ke branch `main` atau `master`.
2. Anda membuat tag rilis (misal `git tag v1.0.0 && git push origin v1.0.0`).
3. Anda menekan tombol **"Run workflow"** secara manual di tab **Actions** di GitHub.

### Format Tag Image di GHCR:
- `ghcr.io/<username>/<repo-name>:latest` (saat push ke branch utama)
- `ghcr.io/<username>/<repo-name>:<branch-name>`
- `ghcr.io/<username>/<repo-name>:<version>` (saat push tag semver seperti `v1.0.0`)
- `ghcr.io/<username>/<repo-name>:<git-sha>` (sha commit)

---

## 💻 Menjalankan Secara Lokal dengan Docker Compose

Untuk menjalankan di komputer Anda secara lokal:

```bash
# Build dan jalankan container
docker compose up -d --build

# Cek status container
docker compose ps

# Lihat logs PHP-FPM dan Nginx
docker compose logs -f app
```

Buka browser Anda di `http://localhost:8000`. Anda akan melihat halaman informasi sistem PHP dan arsitektur CPU (`aarch64` atau `x86_64`).

---

## 📦 Menggunakan Image Hasil Build di Server / Device ARM

Setelah GitHub Actions selesai membuild image, Anda dapat langsung menjalankannya di server ARM (seperti Raspberry Pi, Mac Apple Silicon, atau VPS ARM seperti Oracle Ampere / AWS Graviton).

### 1. Login ke GHCR di Server (Jika Repo Private):
```bash
echo "<GITHUB_PERSONAL_ACCESS_TOKEN>" | docker login ghcr.io -u <GITHUB_USERNAME> --password-stdin
```
*(Jika repositori Anda berstatus Public, langkah login ini tidak diperlukan).*

### 2. Jalankan Container:
```bash
docker run -d \
  --name my-php-app \
  -p 80:80 \
  -v $(pwd):/var/www/html \
  -e DOCUMENT_ROOT=/var/www/html/public \
  ghcr.io/<username>/<repo-name>:latest
```

Docker akan secara otomatis mendeteksi arsitektur ARM perangkat Anda dan mengunduh layer `linux/arm64` tanpa konfigurasi tambahan!
