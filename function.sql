CREATE OR REPLACE
    FUNCTION dist_state_search(z integer, x integer, y integer, query_params json)
    RETURNS bytea AS $$
DECLARE
  mvt bytea;
BEGIN
  SELECT INTO mvt ST_AsMVT(tile, 'districts', 4096, 'geom') FROM (
    SELECT
      ST_AsMVTGeom(
          ST_Transform(ST_CurveToLine(geom), 3857),
          ST_TileEnvelope(z, x, y),
          4096, 64, true) AS geom
    FROM districts
    WHERE geom && ST_Transform(ST_TileEnvelope(z, x, y), 4326)
    AND st_nm = query_params->>'nm'
  ) as tile WHERE geom IS NOT NULL;

  RETURN mvt;
END
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;
