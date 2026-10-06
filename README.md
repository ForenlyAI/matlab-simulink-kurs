# MATLAB ve Simulink 101 — kurs dosyaları

Forenly AI Academy'deki **MATLAB ve Simulink 101** kursunun laboratuvar dosyaları. Derslerde ekranda gördüğünüz her komut, grafik ve Simulink modeli bu betiklerle üretildi.

## Gerekenler

- **MATLAB R2026b ve Simulink.** Ek araç kutusu gerekmez.
- MATLAB ücretli bir yazılımdır. Kendi lisansınızla ya da MathWorks'ün [30 günlük ücretsiz denemesiyle](https://www.mathworks.com/campaigns/products/trials.html) çalışabilirsiniz. Deneme hesabıyla [MATLAB Online](https://matlab.mathworks.com/) da kullanılabilir: bu klasörü yükleyip aynı betikleri çalıştırın.

## Nasıl çalıştırılır

1. Bu depoyu indirin (Code → Download ZIP) ve MATLAB'da klasörü açın.
2. Tek bir haftayı çalıştırmak için komut penceresine `hafta1` yazın (`hafta2`, `hafta3`, `hafta4`).
3. Hepsini sırayla çalıştırmak için `lab_calistir` yazın. Bittiğinde `cikti/BITTI.txt` oluşur; `cikti/kosum.log` içinde `HATA` satırı olmamalıdır.

Betikler çalışınca şu klasörler oluşur: `ekran/` (grafikler ve komut kayıtları), `modeller/` (Simulink modelleri), `cikti/` (sonuç dosyaları), `OLCUMLER.json` (ölçülen sayılar).

## Sonucunuzu karşılaştırın

`beklenen/OLCUMLER.json` ekibimizin 2026-10-06 koşumunda ölçtüğü sayılardır. Kendi `OLCUMLER.json` dosyanızla karşılaştırın. `beklenen/ayar_karsilastirma.csv` Ders 4.3'teki tablodur.

Bitirme projesi (Ders 4.4) geçme ölçütü: ortalama (karesel) hata 1 dereceden az, en büyük tork en fazla 25 N·m.

## Dosyalar

| Dosya | İçerik |
|---|---|
| `hafta1.m` … `hafta4.m` | Her haftanın dört dersi, sırayla |
| `ileri_kinematik.m` | Ders 1.4'te yazılan fonksiyon |
| `dirsek_pd_model.m`, `eklem_model.m` | Simulink modellerini kuran fonksiyonlar (Hafta 3–4) |
| `adim_bilgi.m` | Aşım, yerleşme süresi ve kalıcı hata ölçümü |
| `komut.m`, `sekil.m`, `yeni_sekil.m`, `model_ciz.m`, `olc.m`, `lab_kok.m` | Kayıt ve çizim yardımcıları |
| `veri/cay_servisi_kd_v017_81_0013.hdf5` | Çay servisi benzetim kaydı: 53 eklem × 5666 örnek, sağ bilek duruşu, başarı bilgisi |
| `veri/cay_servisi_kaydi.csv` | Aynı kayıttan sağ kol eklemleri (omuz roll, omuz pitch, dirsek, bilek pitch) ve bardak konumu |
| `veri/g1_kol_eklemleri.csv` | G1 sağ kol eklem sınırları ve kazançları |
| `veri/egitim_kaybi.csv` | π0.5 eğitiminin kayıp eğrisi (2500 adım) |

## Veri hakkında

Robot verisinin tamamı **benzetim kaydıdır**, gerçek robot ölçümü değildir. Kayıt, Forenly AI'nin [kıraathane projesinde](https://forenly.ai/work/kiraathane) Unitree G1 insansı robotunun çay servisini benzetimde yaptığı bir bölümden alınmıştır. Derslerdeki modeller basitleştirilmiş, tek eklemli modellerdir.

Dosyalar yalnız eğitim amacıyla paylaşılmıştır. © Forenly AI
