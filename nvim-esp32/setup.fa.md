# راهنمای راه‌اندازی

## ۱. پیش‌نیازها

- Neovim نسخهٔ 0.11 یا جدیدتر، برای APIهای داخلی LSP و تکمیل کد.
- clangd برای تحلیل C/C++؛ بستهٔ LLVM ویندوز آن را دارد.
- PlatformIO Core و پکیج‌های مربوط به برد و framework پروژه.
- برای آپلود و سریال: اتصال USB و درایور مناسب رابط USB-to-Serial برد.

در محیط بررسی‌شده، Neovim نسخهٔ 0.12.6، clangd نسخهٔ 23.1.3 و PlatformIO Core نسخهٔ 6.2.0 نصب بودند. این‌ها نسخه‌های مشاهده‌شده‌اند؛ لازم نیست دقیقاً همین نسخه‌ها را نصب کنی.

اگر Neovim و LLVM نصب نیستند، در PowerShell:

```powershell
winget install --id Neovim.Neovim -e
winget install --id LLVM.LLVM -e
```

ترمینال جدید باز کن تا PATH تازه شود. برای بررسی:

```powershell
nvim --version
clangd --version
& "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe" --version
```

فرمان سوم برای نصب فعلی PlatformIO روی این سیستم است. اگر `pio` در PATH باشد، `pio --version` هم کافی است. این تنظیم PlatformIO را نصب نمی‌کند.

## ۲. نصب فایل تنظیم

داخل Neovim:

```vim
:echo stdpath('config')
```

مسیر معمول ویندوز `%LOCALAPPDATA%\nvim` است؛ اگر از پروفایل دیگری با `NVIM_APPNAME` استفاده می‌کنی، خروجی خود فرمان ملاک است.

پوشه را در صورت نیاز بساز و [init.lua](init.lua) را داخل آن کپی کن. اگر از قبل تنظیم داری، ابتدا نسخهٔ پشتیبان بگیر و بخش‌های لازم را ادغام کن. داشتن هم‌زمان `init.vim` و `init.lua` در یک پوشهٔ تنظیم مناسب نیست؛ یکی را به‌عنوان نقطهٔ شروع نگه دار.

اگر هیچ تنظیم قبلی نداری و مسیر پیش‌فرض را استفاده می‌کنی، در PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:LOCALAPPDATA\nvim"
Copy-Item '.\nvim-esp32\init.lua' "$env:LOCALAPPDATA\nvim\init.lua"
```

دستور کپی را از ریشهٔ clone این مخزن اجرا کن. ممکن است فایل موجود را جایگزین کند؛ فقط در حالت گفته‌شده استفاده کن.

برای امتحان بدون جایگزینی تنظیم فعلی هم می‌توانی اجرا کنی:

```powershell
nvim -u .\nvim-esp32\init.lua
```

پس از تغییر تنظیم اصلی، Neovim را ببند و دوباره باز کن. اجرای چندبارهٔ `:source` روی این فایل ممکن است autocmdهای تکراری بسازد؛ علت در شرح فنی آمده است.

## ۳. بازکردن پروژه

پروژه‌های firmware بخشی از این مخزن نیستند. یک پروژهٔ PlatformIO موجود را باز کن یا آن را با PlatformIO ایجاد کن؛ board و framework در `platformio.ini` همان پروژه مشخص می‌شوند. مسیرهای زیر مثال‌اند و باید با مسیر پروژهٔ خودت جایگزین شوند.

برای نمونه، پروژهٔ Arduino:

```powershell
cd D:\Programming\esp32-blink
nvim src/main.cpp
```

برای ESP-IDF:

```powershell
cd D:\Programming\esp32-sensor
nvim src/main.c
```

بازکردن Neovim از ریشهٔ پروژه باعث می‌شود مرور فایل‌ها و مسیرهای نسبی هم با همان پروژه هماهنگ باشند.

## ۴. ساخت اطلاعات کامپایل

هنگامی که فایل پروژه باز است:

```vim
:PioCompdb
```

این فرمان معادل `pio run -t compiledb` در ریشهٔ پروژه است. در اجرای موفق، PlatformIO به‌طور معمول `compile_commands.json` را کنار `platformio.ini` تولید می‌کند. این فایل، فرمان کامپایل فایل‌های منبع، مسیر includeها و defineهای مؤثر را ثبت می‌کند.

اولین اجرا ممکن است به اینترنت برای دریافت پکیج‌ها نیاز داشته باشد. صبر کن تا خروجی موفقیت را ببینی. سپس با دو بار `Esc` از حالت Terminal خارج شو، با `:q` پنجرهٔ خروجی را ببند و Neovim را دوباره باز کن.

اگر ترجیح می‌دهی از PowerShell اجرا کنی:

```powershell
& "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe" run -t compiledb
Test-Path .\compile_commands.json
```

این فرمان‌ها را در پوشهٔ حاوی `platformio.ini` اجرا کن. پس از تغییر framework، کتابخانه‌ها، build flags یا محیط هدف، اطلاعات کامپایل را دوباره بساز. هر پروژه فایل خودش را لازم دارد.

## ۵. بررسی نتیجه

فایل `src/main.cpp` را باز کن و اجرا کن:

```vim
:checkhealth vim.lsp
```

در بخش Active Clients باید `clangd`، ریشهٔ درست پروژه و حداقل یک buffer متصل دیده شود. غیرفعال‌بودن File Watcher به‌تنهایی خطای اتصال نیست.

سپس بررسی عملی انجام بده:

1. روی یک تابع یا متغیر `K` بزن؛ اطلاعات آن باید باز شود.
2. روی یک نماد `gd` بزن؛ اگر تعریف قابل‌دسترسی باشد باید به آن بروی.
3. در Arduino، بعد از `Serial.` در حالت Insert، `Ctrl+Space` بزن.
4. با `:PioBuild` ساخت واقعی را بررسی کن؛ سالم‌بودن LSP تضمین ساخت نیست.

## ۶. عیب‌یابی

| نشانه | بررسی و اقدام |
|---|---|
| فرمان `PioBuild` ناشناخته است | `:echo $MYVIMRC` را ببین؛ فایل تنظیم موردنظر بارگذاری نشده یا در زمان اجرا خطا داشته است. `:messages` را بررسی کن. |
| clangd در Active Clients نیست | فایل C/C++ باز کن؛ `:set filetype?` باید `c` یا `cpp` باشد. مسیر clangd و نسخهٔ Neovim را بررسی کن. |
| `Arduino.h` یا هدرهای ESP-IDF پیدا نمی‌شوند | موفقیت `PioCompdb`، محل `compile_commands.json` و تطابق آن با پروژه را بررسی کن. |
| clangd به گزینهٔ کامپایلر یا target اعتراض می‌کند | متن دقیق خطا و log را بررسی کن؛ بعضی گزینه‌های GCC مخصوص Xtensa با نسخهٔ نصب‌شدهٔ clangd سازگار نیستند. حذف عمومی flags یا افزودن دستی انبوه includeها راه‌حل مطمئنی نیست. |
| پیشنهاد تکمیل خودکار ظاهر نمی‌شود | با `Ctrl+Space` درخواست بده؛ تکمیل خودکار داخلی الزاماً با هر حرف باز نمی‌شود. اگر این کلید در ترمینال دریافت نشد، موقتاً `:lua vim.lsp.completion.get()` را امتحان کن یا کلید را در تنظیم عوض کن. |
| فرمان pio پیدا نمی‌شود | کد ابتدا PATH و سپس `~/.platformio/penv/Scripts/pio.exe` را بررسی می‌کند. نصب سفارشی مسیر متفاوت می‌خواهد. |
| PermissionError در `.platformio` | فرمان را در PowerShell معمولی خودت امتحان کن و دسترسی پوشه و قفل‌های فرایندهای دیگر را بررسی کن. خطای محدودیت محیط ابزار را با نیاز به اجرای همیشگی Administrator یکی ندان. |
| آپلود خطای پورت دارد | کابل داده، درایور، پورت و بسته‌بودن مانیتور سریال را بررسی کن. با `pio device list` پورت‌ها را ببین. |
| سریال خوانا نیست | baud rate برنامه و `monitor_speed` در `platformio.ini` باید یکسان باشند؛ برای نمونه هر دو 115200. |

برای دیدن log، از مسیر گزارش‌شده در health استفاده کن یا بزن:

```vim
:lua vim.cmd.edit(vim.lsp.log.get_filename())
```

در صورت نیاز برای بررسی موقت:

```vim
:lua vim.lsp.set_log_level('debug')
```

بعد از بازتولید مشکل، سطح را با `'warn'` برگردان تا log بی‌دلیل رشد نکند.
