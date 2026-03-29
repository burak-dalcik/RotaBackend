-- IETT-style seed (Rota demo). UTF-8.

CREATE TABLE d_durak (
  sid         INTEGER PRIMARY KEY,
  durakkodu   VARCHAR(64) NOT NULL UNIQUE,
  durakadi    TEXT NOT NULL,
  engellirampa VARCHAR(8) NOT NULL,
  enlem       DOUBLE PRECISION,
  boylam      DOUBLE PRECISION
);

CREATE TABLE d_hat (
  sid     INTEGER PRIMARY KEY,
  hatkodu VARCHAR(32) NOT NULL,
  hatadi  TEXT NOT NULL
);

CREATE TABLE d_arac (
  sid      INTEGER PRIMARY KEY,
  kapino   VARCHAR(64),
  kapasite INTEGER NOT NULL,
  engelli  VARCHAR(8) NOT NULL
);

CREATE TABLE f_sefer_template (
  siddurak         INTEGER NOT NULL REFERENCES d_durak (sid),
  sidhat           INTEGER NOT NULL REFERENCES d_hat (sid),
  sid_arac         INTEGER NOT NULL REFERENCES d_arac (sid),
  minutes_from_now INTEGER NOT NULL,
  PRIMARY KEY (siddurak, sidhat, sid_arac, minutes_from_now)
);

INSERT INTO d_durak (sid, durakkodu, durakadi, engellirampa, enlem, boylam) VALUES
  (1, 'KAD-MRK', 'Kadıköy Merkez', 'E', 40.9908, 29.0237),
  (2, 'BES-MYD', 'Beşiktaş Meydan', 'E', 41.0425, 29.0044),
  (3, 'KAD-SHL', 'Kadıköy Sahil', 'H', 40.9928, 29.0185);

INSERT INTO d_hat (sid, hatkodu, hatadi) VALUES
  (101, '19F', 'FINDIKLI MAHALLESİ - YEDİTEPE ÜNİVERSİTESİ - KADIKÖY'),
  (102, '14ES', 'ESENŞEHİR - ÜMRANİYE - KADIKÖY'),
  (103, '8A', 'BATI ATAŞEHİR - KADIKÖY'),
  (104, 'MR1', 'MARMARAY TRANSFER - KADIKÖY'),
  (105, '500T', 'Tuzla - Cevizlibağ');

INSERT INTO d_arac (sid, kapino, kapasite, engelli) VALUES
  (201, 'A-1001', 85, 'E'),
  (202, 'A-1002', 90, 'E'),
  (203, 'A-1003', 75, 'H'),
  (204, 'A-1004', 110, 'E');

INSERT INTO f_sefer_template (siddurak, sidhat, sid_arac, minutes_from_now) VALUES
  (1, 101, 201, 8),
  (1, 102, 202, 12),
  (1, 103, 203, 24),
  (1, 104, 204, 40),
  (1, 105, 201, 55),
  (2, 105, 202, 6),
  (2, 102, 203, 18),
  (2, 103, 204, 35),
  (3, 103, 201, 9),
  (3, 101, 202, 22),
  (3, 105, 204, 48);
