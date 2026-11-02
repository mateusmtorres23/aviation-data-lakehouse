CREATE LIVE VIEW vra_audited (
  CONSTRAINT scheduled_times_present
    EXPECT (partida_prevista IS NOT NULL AND chegada_prevista IS NOT NULL),

  CONSTRAINT flight_status_known
    EXPECT (situacao_voo IN ('REALIZADO', 'CANCELADO')),

  CONSTRAINT scheduled_arrival_after_scheduled_departure
    EXPECT (
      partida_prevista IS NULL OR chegada_prevista IS NULL
      OR chegada_prevista > partida_prevista
    ),

  CONSTRAINT real_arrival_after_real_departure
    EXPECT (
      partida_real IS NULL OR chegada_real IS NULL
      OR chegada_real > partida_real
    ),

  CONSTRAINT plausible_departure_delay
    EXPECT (partida_delay IS NULL OR partida_delay BETWEEN -120 AND 1440),

  CONSTRAINT plausible_arrival_delay
    EXPECT (chegada_delay IS NULL OR chegada_delay BETWEEN -120 AND 1440),

  CONSTRAINT company_in_anac_registry
    EXPECT (company_registered),

  CONSTRAINT origin_airport_in_anac_registry
    EXPECT (origin_registered),

  CONSTRAINT destination_airport_in_anac_registry
    EXPECT (destination_registered)
)
COMMENT 'Data contract for silver.vra. Nine expectations measure quality without dropping rows. Silver retains its original row count.'
AS SELECT * FROM vra_marked;