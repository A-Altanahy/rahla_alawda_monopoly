class GameSquare {
  final String name;
  final String?
  type; // 'start', 'city', 'station', 'utility', 'card', 'penalty', 'rest', 'jail'
  final int? price;
  final String? description;

  GameSquare({required this.name, this.type, this.price, this.description});
}

final List<GameSquare> boardSquares = [
  // Starting from bottom right corner, going counterclockwise

  // Corner 1: Start (نقطة البداية)
  GameSquare(
    name: "نقطة البداية",
    type: "start",
    description: "نقطة البداية - اجمع 200 دك",
  ),

  // Bottom edge (right to left)
  GameSquare(
    name: "مكة",
    type: "city",
    price: 60,
    description: "المدينة المقدسة",
  ),
  GameSquare(
    name: "صندوق الفاتحين",
    type: "card",
    description: "اسحب بطاقة من صندوق الفاتحين",
  ),
  GameSquare(
    name: "المدينة",
    type: "city",
    price: 60,
    description: "المدينة المنورة",
  ),
  GameSquare(
    name: "كُلفة التقصير",
    type: "penalty",
    price: 200,
    description: "ادفع كلفة التقصير 200 دك",
  ),
  GameSquare(
    name: "محطة الغُزاة",
    type: "station",
    price: 200,
    description: "محطة سكة حديد",
  ),
  GameSquare(
    name: "دمشق",
    type: "city",
    price: 100,
    description: "الشام الشريف",
  ),
  GameSquare(name: "غنيمة", type: "card", description: "اسحب بطاقة غنيمة"),
  GameSquare(name: "حلب", type: "city", price: 100, description: "الشهباء"),
  GameSquare(
    name: "حمص",
    type: "city",
    price: 120,
    description: "مدينة خالد بن الوليد",
  ),

  // Corner 2: Jail (السجن)
  GameSquare(name: "السجن", type: "jail", description: "مجرد زيارة أو محبوس"),

  // Left edge (bottom to top)
  GameSquare(
    name: "البصرة",
    type: "city",
    price: 140,
    description: "فيحاء العراق",
  ),
  GameSquare(
    name: "قلعة الكرك",
    type: "utility",
    price: 150,
    description: "قلعة الكرك التاريخية",
  ),
  GameSquare(
    name: "الكوفة",
    type: "city",
    price: 140,
    description: "مدينة الإمام علي",
  ),
  GameSquare(
    name: "بغداد",
    type: "city",
    price: 160,
    description: "عاصمة الرشيد",
  ),
  GameSquare(
    name: "محطة الثبات",
    type: "station",
    price: 200,
    description: "محطة سكة حديد",
  ),
  GameSquare(
    name: "القاهرة",
    type: "city",
    price: 180,
    description: "أم الدنيا",
  ),
  GameSquare(
    name: "صندوق الفاتحين",
    type: "card",
    description: "اسحب بطاقة من صندوق الفاتحين",
  ),
  GameSquare(
    name: "الاسكندرية",
    type: "city",
    price: 180,
    description: "عروس البحر المتوسط",
  ),
  GameSquare(
    name: "المنصورة",
    type: "city",
    price: 200,
    description: "المنصورة المجيدة",
  ),

  // Corner 3: Free Parking (دار الضيافة)
  GameSquare(name: "دار الضيافة", type: "rest", description: "استراحة مجانية"),

  // Top edge (left to right)
  GameSquare(
    name: "فاس",
    type: "city",
    price: 220,
    description: "مدينة فاس العتيقة",
  ),
  GameSquare(name: "غنيمة", type: "card", description: "اسحب بطاقة غنيمة"),
  GameSquare(
    name: "القيروان",
    type: "city",
    price: 220,
    description: "رابعة الحرمين الشريفين",
  ),
  GameSquare(
    name: "تلمسان",
    type: "city",
    price: 240,
    description: "لؤلؤة المغرب العربي",
  ),
  GameSquare(
    name: "محطة الرباط",
    type: "station",
    price: 200,
    description: "محطة سكة حديد",
  ),
  GameSquare(
    name: "قرطبة",
    type: "city",
    price: 260,
    description: "عاصمة الأندلس",
  ),
  GameSquare(
    name: "إشبيلية",
    type: "city",
    price: 260,
    description: "مدينة إشبيلية الأندلسية",
  ),
  GameSquare(
    name: "قلعة حلب",
    type: "utility",
    price: 150,
    description: "قلعة حلب التاريخية",
  ),
  GameSquare(
    name: "غرناطة",
    type: "city",
    price: 280,
    description: "آخر معاقل المسلمين في الأندلس",
  ),

  // Corner 4: Go to Jail (اذهب إلى السجن)
  GameSquare(
    name: "اذهب إلى السجن",
    type: "penalty",
    description: "اذهب مباشرة إلى السجن",
  ),

  // Right edge (top to bottom)
  GameSquare(
    name: "إسطنبول",
    type: "city",
    price: 300,
    description: "عاصمة الخلافة العثمانية",
  ),
  GameSquare(
    name: "بخارى",
    type: "city",
    price: 300,
    description: "مدينة بخارى التاريخية",
  ),
  GameSquare(
    name: "صندوق الفاتحين",
    type: "card",
    description: "اسحب بطاقة من صندوق الفاتحين",
  ),
  GameSquare(
    name: "سمرقند",
    type: "city",
    price: 320,
    description: "جوهرة طريق الحرير",
  ),
  GameSquare(
    name: "محطة النصر",
    type: "station",
    price: 200,
    description: "محطة سكة حديد",
  ),
  GameSquare(name: "غنيمة", type: "card", description: "اسحب بطاقة غنيمة"),
  GameSquare(
    name: "غزة",
    type: "city",
    price: 350,
    description: "مدينة غزة الصامدة",
  ),
  GameSquare(
    name: "كلفة التقصير",
    type: "penalty",
    price: 100,
    description: "ادفع كلفة التقصير 100 دك",
  ),
  GameSquare(
    name: "القدس",
    type: "city",
    price: 400,
    description: "أولى القبلتين وثالث الحرمين الشريفين",
  ),
];
