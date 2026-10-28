В коде реализована [Абелева песочная куча](https://en.wikipedia.org/wiki/Abelian_sandpile_model)

## Сборка и запуск
```bash
clang -O2 -Wall -Wextra start.c sim.c app.c -lSDL2 -o app
./app
```

## LLVM IR
```bash
clang -O2 -S -emit-llvm app.c -o app-opt.ll
```

app-opt.ll - IR симуляции (app.c), сгенерированный оптимизацией с -O2

## IRTrace.cpp
```bash
clang++ IRTrace.cpp -fPIC -shared   $(llvm-config --cxxflags) -o libIRTrace.so
clang -O2 -fpass-plugin=./libIRTrace.so -c app.c -o app.o
clang  -O2 app.o sim.c start.c log.c -lSDL2 -o app-traced
./app-traced > log.txt
```

Был проанализирован файл на 4.77 гб (325,806,404) строк
Результаты анализа в patterns.txt в виде

===== {window size (lines)} (uniq: {uniq operations (lines)}) =====
{pattern count}  {pattern}

Скрипт для анализа лежит в analyze.py
Пример запуска
```
python3 analyze.py log.txt --top 50 -o patterns.txt
```

## IRGen
```bash
clang++ $(llvm-config --cppflags --ldflags --libs) \
  sim.c IRGen/app_ir_gen.cpp -lSDL2 -o ir_generator
```