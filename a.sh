#!/bin/bash

url="https://dlcdn.apache.org/hadoop/common/stable/"
versi_pattern="hadoop-[0-9]+\.[0-9]+\.[0-9]+"
arsitektur=$(uname -m)

# Tambahkan aarch64 ke pattern jika arsitektur adalah arm64
if [ "$arsitektur" = "aarch64" ]; then
  versi_pattern+="|hadoop-[0-9]+\.[0-9]+\.[0-9]+-aarch64"
fi

# Ambil nama contoh Hadoop-versi
nama=$(curl -s "$url" | grep -oE "$versi_pattern" | sort -V | tail -n1)

# Jika nama tidak ditemukan, tampilkan pesan kesalahan
if [ -z "$nama" ]; then
  echo "Nama Hadoop-versi tidak ditemukan"
  exit 1
fi

# Tampilkan nama contoh Hadoop-versi
echo "Nama Hadoop-versi: $nama"

# Download file menggunakan perintah wget
echo "Mendownload $nama"
wget "$url$nama.tar.gz"

