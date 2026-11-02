CREATE OR REFRESH MATERIALIZED VIEW vra_quarantine
COMMENT 'Diagnostic copy of Silver records that fail quality rules, with reasons for investigation. The original silver.vra remains unchanged.'
AS
SELECT
  *,
  concat_ws(' | ',
    CASE WHEN partida_prevista IS NULL OR chegada_prevista IS NULL
      THEN 'scheduled_times_present' END,

    CASE WHEN situacao_voo NOT IN ('REALIZADO', 'CANCELADO')
              OR situacao_voo IS NULL
      THEN 'flight_status_known' END,

    CASE WHEN partida_prevista IS NOT NULL
              AND chegada_prevista IS NOT NULL
              AND chegada_prevista <= partida_prevista
      THEN 'scheduled_arrival_after_scheduled_departure' END,

    CASE WHEN partida_real IS NOT NULL
              AND chegada_real IS NOT NULL
              AND chegada_real <= partida_real
      THEN 'real_arrival_after_real_departure' END,

    CASE WHEN partida_delay IS NOT NULL
              AND (partida_delay < -120 OR partida_delay > 1440)
      THEN 'plausible_departure_delay' END,

    CASE WHEN chegada_delay IS NOT NULL
              AND (chegada_delay < -120 OR chegada_delay > 1440)
      THEN 'plausible_arrival_delay' END,

    CASE WHEN NOT company_registered
      THEN 'company_in_anac_registry' END,

    CASE WHEN NOT origin_registered
      THEN 'origin_airport_in_anac_registry' END,

    CASE WHEN NOT destination_registered
      THEN 'destination_airport_in_anac_registry' END
  ) AS quarantine_reasons,
  current_timestamp() AS _quarantine_on
FROM vra_audited
WHERE NOT (
      partida_prevista IS NOT NULL AND chegada_prevista IS NOT NULL
  AND situacao_voo IN ('REALIZADO', 'CANCELADO')
  AND (
    partida_prevista IS NULL OR chegada_prevista IS NULL
    OR chegada_prevista > partida_prevista
  )
  AND (
    partida_real IS NULL OR chegada_real IS NULL
    OR chegada_real > partida_real
  )
  AND (partida_delay IS NULL OR partida_delay BETWEEN -120 AND 1440)
  AND (chegada_delay IS NULL OR chegada_delay BETWEEN -120 AND 1440)
  AND company_registered
  AND origin_registered
  AND destination_registered
);