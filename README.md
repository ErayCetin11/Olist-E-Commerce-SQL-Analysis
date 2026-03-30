# Olist E-Commerce SQL Analysis

Brezilyalı e-ticaret devi Olist'in 2016-2018 yılları arasındaki verilerini kullanarak gerçekleştirdiğim uçtan uca veri analizi projesidir.

##  Proje Özeti
Bu proje, ham verilerin SQL (T-SQL) kullanılarak işlenmesi anlamlı veriye dönmesini sağlar.

Bu projede kullanılan veriler, Kaggle üzerinden erişilebilen [Olist - Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) setidir.

### Kullanılan Tablolar 
Analizler sırasında aşağıdaki tablolar birbirine bağlanarak kullanılmıştır kullanılan bazı sütun adlarınada aşşağıda yer verilmiştir:

* **Siparisler (Orders):** Sipariş tarihi, teslimat bilgileri ve durumu.
* **Müsteriler (Customers):** Müşteri lokasyonları ve tekil ID'leri.
* **sipariş_detay (Order_Items):** Ürün fiyatı, kargo limiti ve ürün ID'leri.
* **Urunler (Products):** Ürün kategorileri ve fiziksel özellikleri.
* **ödeme_yöntemi (Payments):** Ödeme tipi ve taksit bilgileri.
* **Geri_Bildirim (Reviews):** Müşteri memnuniyet puanları ve yorumlar.

## Öne Çıkan Analizler
* **Lojistik Hata Tespiti:** Gecikmelerin satıcıdan mı yoksa kargo şirketinden mi kaynaklandığını belirleyen özel skorlama mantığı.
* **Sepet Analizi** Kategoriler arası birliktelik oranlarının tespiti vefırsatları.
* **Büyüme Trendleri:** 2016-2018 yılları arası aylık bazda satış raporları.

## SQL (T-SQL / MS SQL Server) Kullanılmıştır.

## Temel Bulgular
* **Ödeme Yöntemi:** Kredi kartı kullanımı, taksit imkanı sayesinde sepet tutarını artırmaktadır.
* **Büyüme:** Platform 2017'den 2018'e geçişte aylık siparişinde büyüme kaydetmiştir.
* **Lojistik:** Gecikmelerin büyük çoğunluğunun satıcıdan ziyade lojistikden kaynaklı olduğu anlaşılmıştır.
