from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sqlite3

app = FastAPI()

# Modelo de partida
class GameData(BaseModel):
    life: int
    gold: int
    days: int
    unlocked_towers: list
    difficulty: str
    towers: list

# Función auxiliar para consultas SQL
def execute_query(query, params=()):
    conn = sqlite3.connect("saves.db")
    cursor = conn.cursor()
    cursor.execute(query, params)
    conn.commit()
    return cursor.fetchall()

# Crear tabla (ejecutar una vez)
execute_query("""CREATE TABLE IF NOT EXISTS games (
    user_id TEXT,
    game_id TEXT PRIMARY KEY,
    data TEXT
)""")


@app.post("/games/{user_id}/{game_id}")
def create_game(user_id: str, game_id: str, game_data: GameData):
    execute_query("INSERT INTO games (user_id, game_id, data) VALUES (?, ?, ?)",
                (user_id, game_id, game_data.model_dump_json()))
    return {"message": f"Partida '{game_id}' creada para el usuario '{user_id}'"}

@app.get("/games/{user_id}/{game_id}")
def load_game(user_id: str, game_id: str):
    result = execute_query("SELECT data FROM games WHERE user_id = ? AND game_id = ?", (user_id, game_id))
    if result:
        return {"game_id": game_id, "data": result[0][0]}
    raise HTTPException(status_code=404, detail="Partida no encontrada")

@app.get("/games/{user_id}")
def list_games(user_id: str):
    result = execute_query("SELECT game_id FROM games WHERE user_id = ?", (user_id,))
    return {"games": [row[0] for row in result]}

@app.put("/games/{user_id}/{game_id}")
def update_game(user_id: str, game_id: str, game_data: GameData):
    execute_query("UPDATE games SET data = ? WHERE user_id = ? AND game_id = ?",
                (game_data.model_dump_json(), user_id, game_id))
    return {"message": f"Partida '{game_id}' actualizada"}

@app.delete("/games/{user_id}/{game_id}")
def delete_game(user_id: str, game_id: str):
    execute_query("DELETE FROM games WHERE user_id = ? AND game_id = ?", (user_id, game_id))
    return {"message": f"Partida '{game_id}' eliminada"}

if __name__ == "__main__":
    # Ejecutar pruebas básicas
    test_user = "uPnklzxoWrfoMNyiHZUsgmUhQbE2"
    test_game = "partida_01q1"
    test_data = GameData(life=100, gold=500, days=3, unlocked_towers=["Archer", "Mage"], difficulty="Normal", towers=[])

    print("\n🔄 Creando partida...")
    create_game(test_user, test_game, test_data)

    print("\n📄 Listando partidas...")
    print(list_games(test_user))

    print("\n🔍 Cargando partida...")
    print(load_game(test_user, test_game))

    print("\n✏️ Actualizando partida...")
    test_data.gold = 999
    update_game(test_user, test_game, test_data)
    print(load_game(test_user, test_game))

    print("\n🗑️ Eliminando partida...")

    print(list_games(test_user))

    print("\n✅ Pruebas completadas.")
