# AutodocFeedApp

Лента новостей на API Autodoc: пагинация, изображения, категории. По тапу новость открывается в браузере.

## Скриншоты

<p align="center">
  <img src="AutodocFeedApp/Resources/Screenshots/iPhone Feed.png" width="250" />
  <img src="AutodocFeedApp/Resources/Screenshots/iPad Feed.png" width="500" />
</p>

## Стек

UIKit (программная вёрстка, без Storyboard) · CompositionalLayout + DiffableDataSource · async/await · Combine · Swift Testing · без сторонних зависимостей · iOS 16+

## Архитектура

**MVVM** с однонаправленным потоком: действие → ViewModel меняет состояние → View реагирует.

- Сеть изолирована за протоколом и подменяется моком в тестах.
- ViewModel не знает про UIKit — тестируется отдельно.
- `async/await` — для сети и загрузки картинок.
- `Combine` — точечно, для биндинга `ViewModel → View` через `@Published`.

## Ключевые решения

- **Загрузчик картинок** (`actor`) с трёхуровневым кэшем: память (`NSCache`) → диск (`Caches`) → сеть. Дедупликация параллельных запросов и отмена загрузки в `prepareForReuse` — нет «прилипания» картинок при скролле. Дисковый кэш — по мотивам [статьи Donny Wals](https://www.donnywals.com/using-swifts-async-await-to-build-an-image-loader/), переработан под UIKit с отменой и memory-уровнем.
- **Адаптивный layout**: 1 колонка на iPhone, 2 на iPad. По `horizontalSizeClass`, поэтому корректен в Split View.
- **Self-sizing ячейки**, изображения 16:9, заглушка для новостей без фото (ровная сетка), отклик на нажатие, поддержка тёмной темы.
- **Единая обработка ошибок** через `Result<_, APIError>` + проверка HTTP-статуса.
- **Пагинация** по `willDisplay` с защитой от повторных и лишних запросов.

## Тесты

Swift Testing на логику ViewModel: загрузка, накопление страниц, обработка ошибки, остановка в конце ленты. Сервис подменяется моком.

## Что можно улучшить

Детальный экран на `WKWebView` с hero-переходом · обработка офлайна · очистка дискового кэша по размеру/возрасту · downsampling картинок · pull-to-refresh.
