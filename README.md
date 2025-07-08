# anti-steamid-changer

## 🇺🇸 English Description

**anti_bota.sma** is an AMX Mod X script for Counter-Strike 1.6 that uses a **MySQL database** to block players who attempt to **change or spoof their SteamID**, and also **prevents bots** from joining the server.

### ✅ Key Features
- Uses a **MySQL database** to store and validate SteamIDs.
- **Blocks bots** and **players with fake or changing SteamIDs**.
- Unlike other scripts, it **does not falsely kick players** who share the same IP address.

### 📦 Requirements
- Counter-Strike 1.6 server
- AMX Mod X
- MySQL database

### ⚙️ Installation & Setup

1. **Compile the plugin:**
   - Place `anti_bota.sma` in `addons/amxmodx/scripting/`
   - Compile using AMX Mod X compiler
   - Move the compiled `anti_bota.amxx` to `addons/amxmodx/plugins/`

2. **Enable the plugin:**
   - Add this line to `addons/amxmodx/configs/plugins.ini`:
     ```
     anti_bota.amxx
     ```

3. **Enable the MySQL module:**
   - Open `addons/amxmodx/configs/modules.ini`
   - Make sure the following line is **uncommented**:
     ```
     mysql
     ```

4. **Set MySQL configuration using CVARs:**
   - Add the following lines to `amxx.cfg`:
     ```cfg
     anti_bota_host "127.0.0.1"
     anti_bota_user "root"
     anti_bota_pass "1234"
     anti_bota_dbname "anti_fakeplayers_ct_spawn"
     ```
     

---

## 🇸🇦 الوصف بالعربية

**anti_bota.sma** هو سكربت لـ AMX Mod X للعبة **Counter-Strike 1.6**، يستخدم قاعدة بيانات **MySQL** لمنع اللاعبين الذين يحاولون **تغيير أو تزوير SteamID** من الدخول، كما يمنع **البوتات** من دخول السيرفر.

### ✅ الميزات الرئيسية
- يستخدم **قاعدة بيانات MySQL** للتحقق من SteamID.
- **يمنع دخول البوتات** واللاعبين الذين يحاولون تغيير SteamID.
- **لا يطرد اللاعبين ظلماً** الذين يشاركون نفس الـ IP، بخلاف السكربتات الأخرى.

### 📦 المتطلبات
- سيرفر Counter-Strike 1.6
- AMX Mod X
- قاعدة بيانات MySQL

### ⚙️ طريقة التثبيت والإعداد

1. **ترجمة السكربت:**
   - ضع الملف `anti_bota.sma` داخل `addons/amxmodx/scripting/`
   - استخدم مترجم AMX Mod X للحصول على `anti_bota.amxx`
   - انسخ الملف المترجم إلى `addons/amxmodx/plugins/`

2. **تفعيل السكربت:**
   - أضف السطر التالي إلى ملف `addons/amxmodx/configs/plugins.ini`:
     ```
     anti_bota.amxx
     ```

3. **تفعيل MySQL:**
   - افتح الملف `addons/amxmodx/configs/modules.ini`
   - أزل التعليق عن السطر:
     ```
     mysql
     ```

4. **إعداد قاعدة البيانات باستخدام CVARs:**
   - أضف الأسطر التالية إلى `amxx.cfg`:
     ```cfg
     anti_bota_host "127.0.0.1"
     anti_bota_user "root"
     anti_bota_pass "1234"
     anti_bota_dbname "anti_fakeplayers_ct_spawn"
     ```
