import UIKit

class Spaceship {
    let name = ""
}

// у этого класса инициализатор по умолчанию — без аргументов
let ship = Spaceship() // ✅ всё ок

// а вот так будет ошибка:
let ship2 = Spaceship(name: "Apollo")
// ❌ Argument passed to call that takes no arguments
