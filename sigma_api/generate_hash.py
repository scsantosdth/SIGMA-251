# generate_hash.py
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Generar hash para admin123
password = "admin123"
hashed = pwd_context.hash(password)

print("=" * 50)
print(f"Password: {password}")
print(f"Hash: {hashed}")
print("=" * 50)
print("\nEjecuta en PostgreSQL:")
print(f"UPDATE usuarios SET password_hash = '{hashed}' WHERE username = 'admin';")