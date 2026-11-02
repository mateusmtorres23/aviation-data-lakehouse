CREATE TEMPORARY VIEW vra_marked AS
WITH aerodromo AS (
    SELECT DISTINCT icao FROM aviation.silver.airfield
    WHERE icao IS NOT NULL AND icao <> ""
),
companies AS (
    SELECT DISTINCT icao FROM aviation.silver.companies
    WHERE icao IS NOT NULL AND icao <> ""
)
SELECT
  v.*,
  (ao.icao IS NOT NULL) AS origin_registered,
  (ad.icao IS NOT NULL) AS destination_registered,
  (cm.icao IS NOT NULL) AS company_registered
FROM aviation.silver.vra v
LEFT JOIN airfield ao ON v.icao_aerodromo_origem = ao.icao
LEFT JOIN airfield ad ON v.icao_aerodromo_destino = ad.icao
LEFT JOIN companies cm ON v.icao_empresa_aerea = cm.icao