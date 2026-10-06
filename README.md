# Simulink: Bloklarla Model ve PID — kurs dosyaları

Forenly AI Academy'deki **Simulink: Bloklarla Model ve PID** kursunun laboratuvar dosyaları. Derslerde ekranda gördüğünüz her komut, grafik ve Simulink modeli bu betiklerle üretildi. (Kursun eski adı "MATLAB ve Simulink'le Eklem Kontrolü" idi; MATLAB dersleri artık ayrı bir kursta: [MATLAB'la Veriden Sonuca](https://github.com/ForenlyAI/matlab-veriden-sonuca-kurs).)

## Gerekenler

- **MATLAB R2026b ve Simulink.** Ek araç kutusu gerekmez.
- MATLAB ve Simulink ücretli yazılımlardır. Kendi lisansınızla ya da MathWorks'ün [30 günlük ücretsiz denemesiyle](https://www.mathworks.com/campaigns/products/trials.html) çalışabilirsiniz.

## Hangi ders hangi dosyada

| Ders | Dosya |
|---|---|
| 1.1 İlk Simulink Modeli | `hafta3.m` (ilk bölüm) |
| 1.2 Düşen Bardak · 1.3 Çözücü ve Adım Boyu · 1.4 Kütle-Yay-Sönüm | `yeni-dersler/hafta1.m` |
| 2.1 Eklemi Bloklarla Kurmak · 2.2 Alt Sistem ve Yük · 2.4 Simülasyon Taraması | `hafta3.m` |
| 2.3 Sinyalleri Kaydetmek | `yeni-dersler/hafta234.m` |
| 3.1 Açık Çevrim, Kapalı Çevrim | `yeni-dersler/hafta234.m` |
| 3.2 Tork Sınırı ve Yerçekimi · 3.3 PID · 3.4 Ayarları Karşılaştırmak | `hafta4.m` |
| 4.1 Bozucu Etki · 4.2 Türev Filtresi · 4.3 Fast Restart | `yeni-dersler/hafta234.m` |
| 4.4 Bitirme: Çay Servisini İzlemek | `hafta4.m` (son bölüm) |

`hafta3.m` ve `hafta4.m` içindeki ders numaraları kursun eski sırasına göredir (3.1–4.4); içerik aynıdır. `hafta1.m` ve `hafta2.m` MATLAB ön hazırlığıdır: `hafta2.m` dirseğin eylemsizliğini ve Ders 2.1'de karşılaştırılan ode45 çözümünü üretir, bu yüzden `hafta3.m`'den önce bir kez çalıştırılmalıdır.

## Nasıl çalıştırılır

1. Bu depoyu indirin (Code → Download ZIP) ve MATLAB'da klasörü açın.
2. Ana klasörde `lab_calistir` yazın: `hafta1` … `hafta4` sırayla koşar. Bittiğinde `cikti/BITTI.txt` oluşur; `cikti/kosum.log` içinde `HATA` satırı olmamalıdır.
3. `yeni-dersler` klasörüne geçip orada da `lab_calistir` yazın.

Betikler çalışınca şu klasörler oluşur: `ekran/` (grafikler ve komut kayıtları), `modeller/` (Simulink modelleri), `cikti/` (sonuç dosyaları), `OLCUMLER.json` (ölçülen sayılar).

## Sonucunuzu karşılaştırın

`beklenen/OLCUMLER.json` ve `yeni-dersler/beklenen/OLCUMLER.json` ekibimizin 2026-10-06 koşumunda ölçtüğü sayılardır. Kendi `OLCUMLER.json` dosyanızla karşılaştırın. Ders 4.3'teki süreler (Fast Restart) bilgisayara göre değişir; oranın 1'den büyük olması beklenir. `beklenen/ayar_karsilastirma.csv` Ders 3.4'teki tablodur.

Bitirme projesi (Ders 4.4) geçme ölçütü: ortalama (karesel) hata 1 dereceden az, en büyük tork en fazla 25 N·m.

## Veri hakkında

Robot verisinin tamamı **benzetim kaydıdır**, gerçek robot ölçümü değildir. Kayıt, Forenly AI'nin [kafe projesinde](https://forenly.ai/work/cafe) Unitree G1 insansı robotunun çay servisini benzetimde yaptığı bir bölümden alınmıştır. Derslerdeki modeller basitleştirilmiş, tek eklemli modellerdir; kayıttan ya da eklem kartından gelmeyen değerler ÖRNEK diye işaretlidir.

Dosyalar yalnız eğitim amacıyla paylaşılmıştır. © Forenly AI
