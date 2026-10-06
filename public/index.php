<?php
header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP + Nginx Docker Container</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background: #f4f6f9;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .card {
            background: #fff;
            padding: 32px;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            max-width: 600px;
            width: 100%;
        }
        h1 { color: #2563eb; margin-top: 0; font-size: 1.6rem; }
        .badge {
            display: inline-block;
            padding: 4px 10px;
            font-size: 0.85rem;
            font-weight: 600;
            border-radius: 9999px;
            background: #e0e7ff;
            color: #3730a3;
            margin-right: 6px;
            margin-bottom: 6px;
        }
        .badge-success { background: #dcfce7; color: #166534; }
        .info-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .info-table td { padding: 8px 12px; border-bottom: 1px solid #e5e7eb; font-size: 0.95rem; }
        .info-table td:first-child { font-weight: 600; color: #4b5563; width: 40%; }
        code { background: #f3f4f6; padding: 2px 6px; border-radius: 4px; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 PHP & Nginx Container Berhasil Berjalan!</h1>
        <p>Container All-in-One dengan dukungan Multi-Architecture (ARM64 & AMD64).</p>
        
        <div>
            <span class="badge badge-success">PHP <?= phpversion() ?></span>
            <span class="badge">Nginx Alpine</span>
            <span class="badge">Supervisor</span>
            <span class="badge"><?= php_uname('m') ?></span>
        </div>

        <table class="info-table">
            <tr>
                <td>Arsitektur Sistem</td>
                <td><code><?= htmlspecialchars(php_uname('m')) ?></code></td>
            </tr>
            <tr>
                <td>Sistem Operasi</td>
                <td><code><?= htmlspecialchars(php_uname('s') . ' ' . php_uname('r')) ?></code></td>
            </tr>
            <tr>
                <td>Server API</td>
                <td><code><?= htmlspecialchars(php_sapi_name()) ?></code></td>
            </tr>
            <tr>
                <td>Waktu Server</td>
                <td><?= date('Y-m-d H:i:s T') ?></td>
            </tr>
        </table>
    </div>
</body>
</html>
