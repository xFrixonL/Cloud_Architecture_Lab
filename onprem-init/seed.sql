CREATE TABLE municipal_dump_records (
    record_id SERIAL PRIMARY KEY,
    zone_code VARCHAR(20) NOT NULL,
    location_desc VARCHAR(150) NOT NULL,
    waste_category VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO municipal_dump_records (zone_code, location_desc, waste_category, status) VALUES
('UIO-NORTE-01', 'Av. Galo Plaza Lasso y El Inca', 'Construction Debris', 'PENDING'),
('UIO-CENTRO-04', 'Sector San Roque - Quebrada', 'Household Waste', 'CLEANED'),
('UIO-SUR-09', 'Av. Maldonado y Quitumbe', 'Bulky & Plastic Waste', 'PENDING'),
('UIO-VALLE-02', 'Via Interoceanica Km 12', 'Organic & Yard Waste', 'IN_PROGRESS'),
('UIO-NORTE-07', 'Parque Bicentenario Perimetro Norte', 'Hazardous Electronic', 'PENDING');