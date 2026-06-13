-- =============================================================================
-- despega_auth_demo.sql
-- Setup de autenticacion demo para Despega UTP.
--
-- Contexto:
--   * El login/registro lo maneja el backend en app/api/auth.py.
--   * Contrasena demo UNIVERSAL: demo123  (entra cualquier cuenta sembrada).
--   * Las contrasenas se guardan en TEXTO PLANO -> solo para la demo,
--     NO usar este enfoque en produccion (ahi iria hashing con bcrypt/argon2).
--
-- Este script es IDEMPOTENTE: se puede correr varias veces sin romper nada.
-- Correr con:
--   psql -U postgres -d despega_utp -f despega_auth_demo.sql
-- (o desde pgAdmin / DBeaver pegando el contenido)
-- =============================================================================

-- 1) Asegura la columna password_hash (por si una BD vieja no la tiene).
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash text;

-- 2) Deja explicita la contrasena demo "demo123" en todas las cuentas sembradas.
--    Asi cualquiera del equipo entra con:  <email del usuario>  /  demo123
--    (estudiantes, empresas y asesor).
UPDATE users
SET password_hash = 'demo123'
WHERE password_hash IS NULL
   OR password_hash = 'demo-password-hash';

-- 3) Limpia la cuenta de prueba creada durante el desarrollo (si existe).
DELETE FROM users WHERE email = 'test.empresa@demo.pe';

-- 4) Verificacion rapida (descomenta para ver el resultado):
-- SELECT email, role, (password_hash IS NOT NULL) AS tiene_password
-- FROM users
-- ORDER BY role, email;
