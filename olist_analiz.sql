select
c.product_category_name_english as Katagori_Adi,
count(sd.order_id) as Toplam_Satis_Adedi,
round(sum(sd.price), 2) as Toplam_Ciro,
round(AVG(sd.price), 2) as Ortalama_Ürün_Fiyatı
from sipariş_detay sd
Join Urunler u on Sd.product_id = u.product_id
Join çeviri c on u.product_category_name = c.product_category_name
group by c.product_category_name_english 
order by Toplam_Ciro DESC
---
--- Sağlık en çok ciro kazandıran olduğunu saat ve hediyeliğin ise az satıp çok kazandırdığını görüyoruz , yatak banyo masa nın ise sürümden kazandırdığını çıkarabiliriz adete göre çok kazandırmamış
---
select TOP 10
m.customer_city as Sehir,
count(DISTINCT s.order_id) as Toplam_Siparis_Sayisi,
round(sum(sd.price), 2) AS Toplam_Harcama,
ROUND(SUM(sd.price) / COUNT(DISTINCT s.order_id), 2) AS Ortalama_Siparis_Degeri
from Müsteriler m
join Siparisler s on m.customer_id = s.customer_id
join sipariş_detay sd on s.order_id = sd.order_id
group by m.customer_city
order by Toplam_Siparis_Sayisi desc
-----	
---SAO PAULO deop kurye hizmet gibi yatırımlar artmalı çünkü alışveriş çok oluyor, Salvador ve RİO ise sepet ortalaması daha yüksek insnalar daha lüks pahalı ürün alıyor
select * from(
select top 10
m.customer_city as Sehir,
count(s.order_id) as Toplam_Siparis,
round(AVG(cast(datediff(day, s.order_purchase_timestamp, s.order_delivered_customer_date) as float)), 1) as Ort_Teslimat_Gunu,
ROUND(COUNT(DISTINCT s.order_id) * AVG(CAST(DATEDIFF(day, s.order_purchase_timestamp, s.order_delivered_customer_date) AS FLOAT)), 0) AS Lojistik_Sorun_Skoru
from Müsteriler m
join Siparisler s on m.customer_id = s.customer_id
where s.order_estimated_delivery_date is not null
group by  m.customer_city
having count(s.order_id) > 50
order by Ort_Teslimat_Gunu DESC
) as Yavas_Sehirler
ORDER BY Lojistik_Sorun_Skoru DESC;
---Macapa ve manaus un teslimat gün uzunluğu en çok olsalar bile sipariş sayısı az bu bu tablo ile fortaleza daki problemin daha büyük olduğunu anlıyoruz
select * from(
select top 10
m.customer_city as Sehir,
count(distinct s.order_id) as Toplam_Siparis,
ROUND(AVG(CAST(DATEDIFF(day, s.order_purchase_timestamp, s.order_delivered_customer_date) AS FLOAT)), 1) AS Ort_Teslimat_Gunu,
round(avg(cast(gb.review_score as float)), 1) as Ort_Musteri_Puani,
round(count(distinct s.order_id) * avg(cast(datediff(day, s.order_purchase_timestamp, s.order_delivered_customer_date)as float)),1) as Lojistik_Sorun_Skoru
from Müsteriler m
join Siparisler  s on m.customer_id = s.customer_id
join Geri_Bildirim gb on s.order_id = gb.order_id
where s.order_delivered_customer_date is not null
group by m.customer_city
having count(distinct s.order_id) > 50
order by Ort_Teslimat_Gunu DESC
) as Yavas_Sehirler
order by Lojistik_Sorun_Skoru DESC;
--- FORTELEZA da sorun çok fazla hem teslimat süresi uzun hemde verilen puan olarak çok düşük CAMECARİ ise teslimat süresi diğerlerine göre daha kısa olmasına rağmen verilen puan çok düşük MANAUS un teslimat süresi uzun olmasına rağmen puan yüksek demekki insanlar sabırlı belkide bulundukları coğrafi konum nedeniyle olabilir
--- müşteri puanı teslimata özel bir puan değil sadece bu kadar uzun bekleyip verilen puanın düştüğünü teslimat ile ilgili olduğunu varsaydık 
----------------------------------------------------
------Verilen Teslimat Tarihlerine nerelerde ve yüzde ne kadar tutamıyoruz bunun sonucunda puanımızı etkiliyormu
select top 20
m.customer_city as Sehir,
count(distinct s.order_id) as Toplam_Siparis_Adeti,
sum(case when s.order_delivered_customer_date > s.order_estimated_delivery_date then 1 else 0 end) as Geciken_Siparis_Adeti,
round(cast(sum(case when s.order_delivered_customer_date > s.order_estimated_delivery_date then 1 else 0 end) as float) / count(s.order_id) * 100, 2) as Gecikme_Yuzdesi,
round(avg(case when s.order_delivered_customer_date > s.order_estimated_delivery_date
then cast(datediff(day,s.order_estimated_delivery_date, s.order_delivered_customer_date) AS FLOAT)
else null end),1) as Ort_Gecikme_Gün,
round(avg(cast(gb.review_score as float)),1) as Ort_Musteri_Puani
from Siparisler s
join Müsteriler m on s.customer_id = m.customer_id
left join Geri_Bildirim gb on s.order_id = gb.order_id
WHERE s.order_delivered_customer_date IS NOT NULL
GROUP BY m.customer_city
HAVING COUNT(distinct s.order_id) > 20
ORDER BY Gecikme_Yuzdesi DESC;

----------------------PEKİ BU GECİKMELERİN NEDENİ SATICIMI KARGO ŞİRKETİMİ
WITH En_Sorunlu_Sehirler AS (
    -- Senin ilk sorgundan sadece ilk 20 şehri alıyoruz
    SELECT TOP 20 m.customer_city
    FROM Siparisler s
    JOIN Müsteriler m ON s.customer_id = m.customer_id
    WHERE s.order_delivered_customer_date IS NOT NULL
    GROUP BY m.customer_city
    HAVING COUNT(distinct s.order_id) > 20
    ORDER BY (CAST(SUM(CASE WHEN s.order_delivered_customer_date > s.order_estimated_delivery_date THEN 1 ELSE 0 END) AS FLOAT) / COUNT(s.order_id)) DESC
)
SELECT 
    m.customer_city AS Sehir,
    COUNT(s.order_id) AS Toplam_Geciken_Siparis,
    -- Satıcı Hatası: Ürünü kargoya geç verdi
    SUM(CASE WHEN s.order_delivered_carrier_date > sd.shipping_limit_date THEN 1 ELSE 0 END) AS Satici_Kaynakli_Gecikme,
    -- Kargo Hatası: Satıcı zamanında verdi ama kargo yolda uzadı
    SUM(CASE WHEN s.order_delivered_carrier_date <= sd.shipping_limit_date THEN 1 ELSE 0 END) AS Kargo_Sirketi_Kaynakli_Gecikme
FROM Siparisler s
JOIN Müsteriler m ON s.customer_id = m.customer_id
JOIN sipariş_detay sd ON s.order_id = sd.order_id
-- Sadece en sorunlu 20 şehre odaklanıyoruz:
WHERE m.customer_city IN (SELECT customer_city FROM En_Sorunlu_Sehirler)
  AND s.order_delivered_customer_date > s.order_estimated_delivery_date -- Sadece gecikenler
GROUP BY m.customer_city
ORDER BY Toplam_Geciken_Siparis DESC; ----Tabloya Baktığımızda Kesinlikle Kargo şirketlerinden kaynakli bir gecikme yaşanıyor

select top 20
m.customer_city as Sehir,
gb.review_score as Puan,
gb.review_comment_message as Musteri_Yorumu,
DATEDIFF(day, s.order_purchase_timestamp, s.order_delivered_customer_date) as Teslimat_Gunu
from Müsteriler m
join Siparisler s on m.customer_id = s.customer_id
join Geri_Bildirim gb on s.order_id = gb.order_id
where m.customer_city = 'camacari' and s.order_delivered_customer_date IS NOT NULL
and gb.review_comment_message is not null
order by gb.review_score asc ---NLP DOĞAL DİL İŞLEME

---İNSANLAR EN ÇOK HANGİ ÖDEME YÖNETİMİ KULLANIYOR SEPET TUTARINDAKİ ETKİSİ NEDİR
select
payment_type as Odeme_Yontemi,
count(order_id) as Kullanım_Sayisi,
avg(payment_installments) as Ort_Taksit_Sayisi,
round(avg(payment_value), 2) as Ort_Sepet_Tutari
from ödeme_yöntemi
group by payment_type
ORDER BY Ort_Sepet_Tutari DESC;
---KREDİ KARTI KULLANIM SAYISI ÇOK FAZLA, TAKSİT İMKANI SEPET TUTARINI ARTTIRMIŞ

---Sepet Analizi Hangi kategoride ürün alan yanında genellikle aldığı kategori nedir
select top 20
c1.product_category_name_english AS Kategori_A,
c2.product_category_name_english AS Kategori_B,
count(distinct s1.order_id) as Bİrlikte_Alinma_Sayisi
from sipariş_detay s1
join Urunler u1 on s1.product_id = u1.product_id
join çeviri c1 on u1.product_category_name = c1.product_category_name
join sipariş_detay s2 on s1.order_id = s2.order_id
join Urunler u2 on s2.product_id = u2.product_id
join çeviri c2 on u2.product_category_name = c2.product_category_name
where c1.product_category_name_english < c2.product_category_name_english --KATEGORİNİN KENDİSİ İLE EŞLEŞMESİNİ ENGELLER
group by c1.product_category_name_english, c2.product_category_name_english
ORDER BY Birlikte_Alinma_Sayisi DESC;
----HER YILIN AYLARINA GÖRE YAPTIĞIMIZ SİPARİŞ SAYISINI GÖRMEMİZİ SAĞLAR
SELECT 
    YEAR(order_purchase_timestamp) AS Yil,
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 1 THEN order_id END) AS [Ocak],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 2 THEN order_id END) AS [Şubat],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 3 THEN order_id END) AS [Mart],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 4 THEN order_id END) AS [Nisan],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 5 THEN order_id END) AS [Mayıs],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 6 THEN order_id END) AS [Haziran],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 7 THEN order_id END) AS [Temmuz],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 8 THEN order_id END) AS [Ağustos],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 9 THEN order_id END) AS [Eylül],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 10 THEN order_id END) AS [Ekim],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 11 THEN order_id END) AS [Kasım],
    COUNT(CASE WHEN MONTH(order_purchase_timestamp) = 12 THEN order_id END) AS [Aralık]
FROM Siparisler
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY Yil;
---3 YILLIK BİR VERİSETİ OLDUĞU İÇİN TAM BİR ŞEY DEMEK ZORDUR AMA 2017 DEKİ KASIM AYINDAKİ ARTIK BLACK FRİDAY KAMPANYASI YAPMIŞ OLABİLİR
--- VE İLK BAŞLARDA ORTALAMA 1400 LERDE GEZEN SİPARİŞ SAYISI 6BİN 7BİN SAYISINA 2018 YILINDA DÜZENLİ BİR ŞEKİLDE ULAŞTIĞINI GÖRÜYORUZ DURUM TANINIRLIK VE BÜYÜMEYİ GÖSTEREBİLİR

