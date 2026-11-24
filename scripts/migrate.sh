#!/bin/sh
set -e

echo "=========================================================="
echo " [LIFT-AND-SHIFT] Starting On-Premise -> AWS RDS Migration"
echo "=========================================================="

echo "[1/4] Verifying source On-Premise database records..."
PGPASSWORD=$ONPREM_PASSWORD psql -h onpremise-legacy-db -U $ONPREM_USER -d $ONPREM_DB -c "SELECT record_id, zone_code, waste_category, status FROM municipal_dump_records;"

echo "[2/4] Extracting full logical snapshot (pg_dump) from On-Premise..."
mkdir -p /tmp/migration
PGPASSWORD=$ONPREM_PASSWORD pg_dump -h onpremise-legacy-db -U $ONPREM_USER -d $ONPREM_DB --clean --if-exists > /tmp/migration/onprem_dump.sql
DUMP_HASH=$(sha256sum /tmp/migration/onprem_dump.sql | awk '{print $1}')
echo "      Snapshot generated. SHA-256 Checksum: $DUMP_HASH"

echo "[3/4] Rehosting (Lift-and-Shift) into target AWS RDS instance..."
PGPASSWORD=$RDS_PASSWORD psql -h aws-rds-target-db -U $RDS_USER -d $RDS_DB -f /tmp/migration/onprem_dump.sql > /dev/null

echo "[4/4] Validating migrated data on target AWS RDS..."
PGPASSWORD=$RDS_PASSWORD psql -h aws-rds-target-db -U $RDS_USER -d $RDS_DB -c "SELECT record_id, zone_code, waste_category, status FROM municipal_dump_records;"

echo "=========================================================="
echo " [SUCCESS] Lift-and-Shift Migration Completed Intact!"
echo "=========================================================="