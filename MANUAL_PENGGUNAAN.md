# MANUAL PENGGUNAAN
## Sistem Prediksi Kinerja Siswa Menggunakan Algoritma Random Forest

---

## BAB 1: PENDAHULUAN

### 1.1 Deskripsi Sistem
Sistem ini adalah aplikasi web untuk memprediksi kinerja siswa menggunakan algoritma Random Forest. Sistem terdiri dari:
- **Backend**: API Flask untuk pemrosesan model machine learning
- **Frontend**: Antarmuka web berbasis React untuk input data siswa
- **Database**: Model Random Forest yang telah dilatih

### 1.2 Persyaratan Sistem
Sebelum menjalankan aplikasi, pastikan komputer Anda telah terinstal:
- Docker (versi 20.10 atau lebih baru)
- Docker Compose (versi 1.29 atau lebih baru)
- Browser web modern (Chrome, Firefox, Edge, atau Safari)

---

## BAB 2: LANGKAH PENGGUNAAN

Langkah-langkah penggunaan sistem Prediksi Kinerja Siswa Menggunakan Algoritma Random Forest diuraikan sebagai berikut:

### 2.1 Menjalankan Aplikasi dengan Docker

#### Langkah 1: Buka Terminal
Buka aplikasi Terminal (Linux/Mac) atau Command Prompt/PowerShell (Windows).

#### Langkah 2: Masuk ke Direktori Proyek
```bash
cd /path/to/Data-Science-Education
```
Ganti `/path/to/Data-Science-Education` dengan lokasi folder proyek Anda.

#### Langkah 3: Jalankan Docker Compose
Ganti `/path/to/Data-Science-Education` dengan lokasi folder proyek Anda.
```bash
docker-compose up --build
```

Tunggu hingga proses build dan deployment selesai. Anda akan melihat output seperti pada Gambar 2.1.

![Gambar 2.1 Output Docker Compose saat aplikasi berjalan](screenshots/docker-running.png)
**Gambar 2.1** Output terminal saat aplikasi berhasil dijalankan

#### Langkah 4: Akses Aplikasi melalui Browser
Setelah proses selesai dan muncul pesan bahwa server berjalan, buka browser web Anda.

Ketikkan alamat berikut pada address bar:
```
http://localhost:3000
```

Aplikasi akan terbuka dan menampilkan halaman utama seperti Gambar 2.2.

![Gambar 2.2 Halaman utama aplikasi](screenshots/homepage.png)
**Gambar 2.2** Tampilan halaman utama sistem prediksi

---

### 2.2 Menggunakan Fitur Prediksi

#### Langkah 1: Mengisi Form Data Siswa
Pada halaman utama, Anda akan melihat form input data siswa. Isi semua field yang tersedia:

1. **Code Module**: Pilih kode modul pembelajaran (contoh: AAA, BBB, CCC, dll)
2. **Code Presentation**: Pilih kode presentasi (contoh: 2013J, 2014B, dll)
3. **Gender**: Pilih jenis kelamin siswa (M untuk Male, F untuk Female)
4. **Region**: Pilih wilayah asal siswa
5. **Highest Education**: Pilih tingkat pendidikan tertinggi
6. **IMD Band**: Pilih kategori Index of Multiple Deprivation
7. **Age Band**: Pilih rentang usia siswa
8. **Num of Prev Attempts**: Masukkan jumlah percobaan sebelumnya (0-6)
9. **Studied Credits**: Masukkan jumlah kredit yang dipelajari (0-240)
10. **Disability**: Pilih status disabilitas (Y atau N)

Contoh pengisian form dapat dilihat pada Gambar 2.3.

![Gambar 2.3 Form pengisian data siswa](screenshots/form-input.png)
**Gambar 2.3** Pengisian data siswa pada form prediksi

#### Langkah 2: Melakukan Prediksi
Setelah semua data terisi dengan lengkap, klik tombol **"Predict"** atau **"Prediksi"** seperti ditunjukkan pada Gambar 2.4.

![Gambar 2.4 Tombol prediksi](screenshots/predict-button.png)
**Gambar 2.4** Lokasi tombol untuk melakukan prediksi

#### Langkah 3: Melihat Hasil Prediksi
Sistem akan memproses data yang Anda masukkan menggunakan model Random Forest. Hasil prediksi akan ditampilkan dalam beberapa detik.

Hasil prediksi akan menunjukkan:
- **Kategori Kinerja**: Pass, Fail, atau Withdrawn
- **Tingkat Kepercayaan**: Persentase keyakinan model terhadap prediksi

Contoh hasil prediksi dapat dilihat pada Gambar 2.5.

![Gambar 2.5 Hasil prediksi berhasil](screenshots/result-pass.png)
**Gambar 2.5** Hasil prediksi menunjukkan siswa diprediksi **Pass** dengan tingkat kepercayaan tinggi

#### Contoh Prediksi dengan Hasil Berbeda

**Contoh 1: Prediksi Fail**
Untuk data siswa dengan karakteristik berisiko tinggi (contoh: banyak percobaan sebelumnya, kredit rendah), sistem akan memprediksi **Fail** seperti pada Gambar 2.6.

![Gambar 2.6 Hasil prediksi fail](screenshots/result-fail.png)
**Gambar 2.6** Hasil prediksi menunjukkan siswa diprediksi **Fail**

**Contoh 2: Prediksi Withdrawn**
Untuk data siswa dengan pola perilaku yang menunjukkan kemungkinan berhenti, sistem akan memprediksi **Withdrawn** seperti pada Gambar 2.7.

![Gambar 2.7 Hasil prediksi withdrawn](screenshots/result-withdrawn.png)
**Gambar 2.7** Hasil prediksi menunjukkan siswa diprediksi **Withdrawn**

---

### 2.3 Fitur Tambahan

#### 2.3.1 Melihat Informasi Model
Untuk melihat informasi tentang model Random Forest yang digunakan, akses endpoint:
```
http://localhost:5000/model-info
```

Informasi yang ditampilkan meliputi:
- Nama model
- Akurasi model
- Jumlah pohon keputusan (estimators)
- Fitur-fitur yang digunakan

Contoh tampilan informasi model terlihat pada Gambar 2.8.

![Gambar 2.8 Informasi model](screenshots/model-info.png)
**Gambar 2.8** Informasi detail tentang model Random Forest

#### 2.3.2 Reset Form
Untuk mengosongkan semua field dan memulai prediksi baru, klik tombol **"Reset"** atau **"Clear Form"** yang terletak di sebelah tombol Predict.

---

### 2.4 Menghentikan Aplikasi

#### Langkah 1: Kembali ke Terminal
Buka kembali terminal yang menjalankan Docker Compose.

#### Langkah 2: Hentikan Container
Tekan `Ctrl + C` pada keyboard untuk menghentikan aplikasi.

#### Langkah 3: Hapus Container (Opsional)
Jika ingin menghapus container sepenuhnya, jalankan perintah:
```bash
docker-compose down
```

Output terminal akan menunjukkan proses penghentian container seperti pada Gambar 2.9.

![Gambar 2.9 Menghentikan aplikasi](screenshots/docker-stop.png)
**Gambar 2.9** Proses penghentian aplikasi Docker

---

## BAB 3: TROUBLESHOOTING

### 3.1 Aplikasi Tidak Bisa Diakses
**Masalah**: Browser menampilkan "Unable to connect" atau "Connection refused"

**Solusi**:
1. Pastikan Docker Compose masih berjalan di terminal
2. Periksa apakah port 3000 dan 5000 tidak digunakan oleh aplikasi lain
3. Coba refresh browser (tekan F5 atau Ctrl+R)

### 3.2 Form Tidak Bisa Disubmit
**Masalah**: Tombol Predict tidak merespon atau muncul error

**Solusi**:
1. Pastikan semua field telah diisi dengan lengkap
2. Periksa koneksi ke backend di `http://localhost:5000`
3. Buka Developer Console (F12) untuk melihat pesan error detail

### 3.3 Error saat Build Docker
**Masalah**: Muncul error saat menjalankan `docker-compose up --build`

**Solusi**:
1. Pastikan Docker daemon sedang berjalan
2. Hapus container dan image lama:
   ```bash
   docker-compose down
   docker system prune -a
   ```
3. Coba build ulang dengan perintah sebelumnya

### 3.4 Prediksi Terlalu Lama
**Masalah**: Hasil prediksi tidak muncul setelah beberapa detik

**Solusi**:
1. Periksa log Docker untuk melihat apakah ada error:
   ```bash
   docker-compose logs backend
   ```
2. Restart aplikasi dengan menekan Ctrl+C kemudian jalankan kembali docker-compose

---

## BAB 4: PENGGUNAAN ALTERNATIF

### 4.1 Menggunakan Script Helper

Proyek ini menyediakan script helper untuk memudahkan deployment:

#### Menjalankan dengan Script
```bash
chmod +x docker-setup.sh
./docker-setup.sh
```

#### Menghentikan dengan Script
```bash
chmod +x docker-stop.sh
./docker-stop.sh
```

### 4.2 Akses API Langsung

Selain melalui antarmuka web, Anda juga bisa mengakses API backend secara langsung menggunakan tools seperti Postman atau curl.

**Contoh Request dengan curl**:
```bash
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "code_module": "AAA",
    "code_presentation": "2013J",
    "gender": "M",
    "region": "East Anglian Region",
    "highest_education": "HE Qualification",
    "imd_band": "10-20%",
    "age_band": "0-35",
    "num_of_prev_attempts": 0,
    "studied_credits": 120,
    "disability": "N"
  }'
```

**Contoh Response**:
```json
{
  "prediction": "Pass",
  "confidence": 0.85,
  "message": "Prediction successful"
}
```

---

## BAB 5: INFORMASI TAMBAHAN

### 5.1 Struktur Proyek
```
Data-Science-Education/
├── backend/              # Backend Flask API
│   ├── app.py           # File utama aplikasi
│   ├── model.py         # Model Random Forest
│   ├── dataset/         # Dataset siswa
│   └── Dockerfile       # Config Docker backend
├── frontend/            # Frontend React
│   ├── src/            # Source code
│   └── Dockerfile      # Config Docker frontend
├── docker-compose.yml  # Konfigurasi Docker Compose
└── README.md           # Dokumentasi teknis
```

### 5.2 Port yang Digunakan
- **Port 3000**: Frontend (React)
- **Port 5000**: Backend (Flask API)

Pastikan kedua port ini tidak digunakan oleh aplikasi lain.

### 5.3 Data yang Digunakan
Model ini dilatih menggunakan dataset **Open University Learning Analytics Dataset (OULAD)** yang berisi informasi tentang:
- 32,593 siswa
- 22 modul pembelajaran
- 7 presentasi
- Berbagai demografi dan karakteristik akademik

### 5.4 Kontak dan Dukungan
Jika mengalami masalah atau memiliki pertanyaan lebih lanjut, silakan:
- Buka issue di repository GitHub
- Lihat dokumentasi teknis di README.md
- Periksa log error di terminal untuk informasi debugging

---

## LAMPIRAN

### Lampiran A: Daftar Nilai Input yang Valid

**Code Module**: 
- AAA, BBB, CCC, DDD, EEE, FFF, GGG

**Code Presentation**: 
- 2013B, 2013J, 2014B, 2014J

**Gender**: 
- M (Male), F (Female)

**Region**: 
- East Anglian Region, Scotland, North Western Region, South East Region, West Midlands Region, Ireland, Yorkshire Region, South Region, London Region, East Midlands Region, North Region, South West Region, Wales

**Highest Education**: 
- Lower Than A Level, A Level or Equivalent, HE Qualification, Post Graduate Qualification

**IMD Band**: 
- 0-10%, 10-20%, 20-30%, 30-40%, 40-50%, 50-60%, 60-70%, 70-80%, 80-90%, 90-100%

**Age Band**: 
- 0-35, 35-55, 55<=

**Disability**: 
- Y (Yes), N (No)

---

**Versi**: 1.0  
**Tanggal**: Oktober 2024  
**Penulis**: Tim Pengembang Sistem Prediksi Kinerja Siswa
