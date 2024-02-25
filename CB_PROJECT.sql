#Query 1
select  distinct(product_code) as Product_Code from fact_events
where base_price > 500 and promo_type = "BOGOF";

#Query 2
 select city as City, count(store_id) as Number_Of_Stores from dim_stores
 group by city
 order by count(store_id) desc;
 
 #Query 3
with x as (select *,round(base_price * `quantity_sold(before_promo)`,2) as Revenue_Before_Promo, 
			case when promo_type = "50% OFF" then round((base_price/2) * `quantity_sold(after_promo)`,2)
				when promo_type = "25% OFF" then round((base_price*(3/4)) * `quantity_sold(after_promo)`,2)
                when promo_type = "33% OFF" then round((base_price*(2/3)) * `quantity_sold(after_promo)`,2)
                when promo_type = "500 Cashback" then round((base_price - 500) * `quantity_sold(after_promo)`,2)
                when promo_type = "BOGOF" then round((base_price/2) * `quantity_sold(after_promo)`,2) 
			end as Revenue_After_Promo from fact_events)
select dc.campaign_name as Campaign_Name,concat(round(sum(x.Revenue_Before_Promo)/1000000,2),' M') as `Total_Revenue(Before_promo)`, concat(round(sum(x.Revenue_After_Promo)/1000000,2),' M') as `Total_Revenue(After_promo)`  
from dim_campaigns as dc
inner join x
on dc.campaign_id = x.campaign_id
group by dc.campaign_id;

#Query 4
with y as (select dp.category as Category,round(avg(((`quantity_sold(after_promo)` - `quantity_sold(before_promo)`)/`quantity_sold(before_promo)`)*100),2) as `ISU%` 
from dim_products as dp
inner join fact_events as fe
on dp.product_code = fe.product_code
where fe.campaign_id = (select campaign_id from dim_campaigns where campaign_name = 'Diwali')
group by dp.category)
select *, rank() over (order by `ISU%` desc) as Rank_Order from y;

#Query 5
with x as (select *,round(base_price * `quantity_sold(before_promo)`,2) as Revenue_Before_Promo, 
			case when promo_type = "50% OFF" then round((base_price/2) * `quantity_sold(after_promo)`,2)
				when promo_type = "25% OFF" then round((base_price*(3/4)) * `quantity_sold(after_promo)`,2)
                when promo_type = "33% OFF" then round((base_price*(2/3)) * `quantity_sold(after_promo)`,2)
                when promo_type = "500 Cashback" then round((base_price - 500) * `quantity_sold(after_promo)`,2)
                when promo_type = "BOGOF" then round((base_price/2) * `quantity_sold(after_promo)`,2) 
			end as Revenue_After_Promo from fact_events)
select x.product_code, round(avg(((Revenue_After_Promo - Revenue_Before_Promo)/Revenue_Before_Promo)*100),2) as `IR%`, rank() over(order by round(avg(((Revenue_After_Promo - Revenue_Before_Promo)/Revenue_Before_Promo)*100),2) desc) 
as Rank_Order from x
group by x.product_code
order by round(avg(((Revenue_After_Promo - Revenue_Before_Promo)/Revenue_Before_Promo)*100),2) desc
limit 5;
                

                


