#import "@preview/physica:0.9.5": *  // Физические формулы
#import "@preview/cetz:0.3.4"        // Диаграммы
#import "@preview/cetz-plot:0.1.1"
#import "@preview/codly:1.3.0": *

#set text(
  font: "Times new roman",
  size: 14pt,
  lang: "ru"
)
#set page(
  paper: "a4",
  margin: (left:3cm, right:1.5cm, y:2cm),
  number-align: right,
)
#set par(
  justify: true,
  first-line-indent:( 
    amount: 1.25cm,
    all:true
  )
)

// Приводит межстрочное состояние в соответствие с вордом
#let leading = 1.5em - 0.75em
#set block(spacing: leading)
#set par(spacing:leading, leading:leading)

#set figure(
  supplement: [Рисунок],
  numbering: (..num) =>
  numbering("1.1", counter(heading).get().first(), num.pos().first())
)

// Для листингов кода
#show: codly-init.with()
#codly(
  display-name: false,
  fill: luma(230)
)

#show figure.where(
  kind: "listing"
): set figure.caption(position: top,separator: [ --- ])
#show figure.caption.where(
  kind: "listing"
): it => [
  #linebreak()
  #align(right)[#it]
]

#show figure.where(
  kind: "table"
): set figure.caption(position: top,separator: [ --- ])
#show figure.caption.where(
  kind: "table"
): it => [
  #linebreak()
  #align(left)[#it]
]

// Название
#align(center)[
  #text[ *Министерство науки и высшего образования Российской Федерации* ]

  #text(hyphenate:false)[ Санкт-Петербургский Политехнический университет Петра Великого \ Институт энергетики \ Высшая школа энергетического машиностроения ] \
]
\ \ \ \ \ \

#align(center)[
  *Отчёт по практической работе №1*\
по дисциплине «Теория автоматического регулирования»\
#text(hyphenate:false)[«Исследование влияния параметров САР паровой турбины на качество переходных процессов»]
]
\ \ \ \ \

#table(
  columns:(1.5fr,1fr,1fr),
  stroke: 0pt,
  row-gutter: 20pt,
  [Выполнили:],[],[],
  [Студент гр.3231303/21201 п/г 2],
  table.cell(align:bottom,underline(stroke:black)[#text(fill:white)[rtrtrttrtrtrtrttrtrtr]]),
  [А. К. Дмитриев],
  [Студент гр.3231303/21201 п/г 2],
  table.cell(align:bottom,underline(stroke:black)[#text(fill:white)[rtrtrttrtrtrtrttrtrtr]]),
  [А. Д. Ярошевич],
  [],[],[],
  [Принял:],[],[],
  [Доцент ВШЭМ],
  underline(stroke:black)[#text(fill:white)[rtrtrttrtrtrtrttrtrtr]],
  [В. А. Суханов]
)

\ \ \ \  

#align(center)[
  Санкт-Петербург\
  2025
]

#show heading:it => {
  set text(hyphenate: false,
    size: 14pt,
    weight: "semibold"
  )
  set block(above: 1.4em, below: 28pt)
  pad(x: 1.25cm, it)
}

#show heading.where(level:1):it => {
  counter(figure.where(kind: image)).update(0)
  it
}

#counter(page).update(0)
#set page(numbering: "1")

#heading(outlined:false)[Реферат]

Отчет объемом 13 страниц, содержит 4 таблицы и 6 рисунков.

В данной лабораторной работе было проведено исследование влияния параметров системы автоматического регулирования (САР) паровой турбины на качество переходных процессов. Основная цель состояла в анализе изменения переходных процессов при варьировании параметров САР: постоянны[] времени ротора, паровой емкости, сервомотора, а также степени неравномерности датчика угловой скорости.

КЛЮЧЕВЫЕ СЛОВА: ПЕРЕХОДНЫЙ ПРОЦЕСС, РОТОР, ПАРОВАЯ ЕМКОСТЬ, СЕРВОМОТОР, СТЕПЕНЬ НЕРАВНОМЕРНОСТИ.

#pagebreak()
#show outline: it => {
  show heading: set align(center)
  show heading: set text(14pt)
  show heading: set block(above: 1.4em, below: 1em)
  it
}
#outline(
  title: "СОДЕРЖАНИЕ",
  indent: auto
)
#pagebreak()

= Введение

Цель работы состоит в исследовании влияния параметров САР на качество переходных процессов и в анализе качества переходных процессов в системе автоматического регулирования (САР) угловой скорости ротора паровой турбины. Работа проведена с помощью пакетов DifferentialEquations.jl и Plots.jl языка программирования Julia в среде Pluto.

Задача исследования заключается в анализе влияния параметров $T_a, T_pi, T_s$ и $delta_omega$ системы автоматического регулирования на качество переходных процессов.

Актуальность исследования заключается в:
+ Повышении экономичности процесса получения энергии на электростанциях;
+ Улучшении эксплуатационных характеристик систем регулирования турбоагрегатов;
+ Значительном увеличение срока службы систем автоматического регулирования турбин САР и повышении их надежности;
+ Качественном повышении показателей переходных процессов и быстродействия, снижение стоимости САР и в итоге снижении стоимости вырабатываемой электроэнергии.

#pagebreak()

#set heading(numbering: "1.1 ")

= Описание исследуемой САР и исходные данные

Объектом исследования является система регулирования угловой скорости ротора паровой турбины без промежуточного перегрева пара, принципиальная схема которой изображена на @SAR[рисунке].

#figure(
  [
    #image("assets/2025-03-22-11-41-02.png", width: 80%)
    #text(size:12pt, hyphenate:false)[1 --- механизм управления; 2 --- сервомотор (гидравлический усилитель);\ 
    3 --- генератор; 
    4 --- паровая ёмкость между регулирующим клапаном и соплами турбины;\ 
    5 --- регулирующий клапан; 
    6 --- ротор турбогенератора; 
    7 --- датчик угловой скорости ротора; 
    $phi$ --- относительное изменение угловой скорости ротора (величина, характеризующая ошибку регулирования); 
    $pi$ --- относительное изменение давление пара перед соплами турбины; 
    $xi$ --- относительное изменение положения регулирующего клапана (или поршня сервомотора); 
    $eta$ --- относительное изменение положения выходной\ координаты элемента сравнения; 
    $nu_г$ --- относительное изменение нагрузки на генераторе;\ 
    $zeta_"му"$ --- относительное изменение положения механизма управления]
  ],
  caption: [Принципиальная схема САР угловой скорости ротора],
) <SAR> \

Исходные значения параметров САР указаны в @ar[таблицы].

#figure(
  table(
    columns: (1fr,1fr,1fr,1fr),
    row-gutter: (1.7pt, auto),
    table.header[$T_a$][$T_pi$][$T_s$][$delta_omega$],
    [$7$],[$0.4$],[$0.7$],[$0.12$]
  ),
  caption: [Назначение промежутков варьирования],
  kind: "table",
  supplement: "Таблица"
) <ar>

#pagebreak()
= Система уравнений, описывающих переходные процессы в исследуемой САР и её перевод в программный вид

В работе рассматривается представление САР в виде линейной математической модели в стандартной форме:

\
$ cases(
    T_a dot dv(phi,t) = pi - nu_г,
    T_pi dot dv(pi,t) + pi = xi,
    T_s dot dv(xi,t) + xi = eta,
    eta = - phi/delta_omega + zeta_"му"
  )
$где #box(baseline: 97.5%,
$ 
  T_a - &"постоянная времени ротора;"\
  T_pi - &"постоянная времени паровой ёмкости;"\
  T_s - &"постоянная времени сервомотора;"\
  delta_omega - &"величина, пропорциональная коэффициенту" \ &"усиления разомкнутой системы;"\
  eta - &"относительное изменение положения выходной" \ &"координаты элемента сравнения;"\
  phi - &"относительное изменение угловой скорости ротора" \ &"турбины и генератора. Характеризует ошибку регулирования;"\
  pi - &"относииельное изменение давления пара в паровой ёмкости;"\
  xi - &"относительное изменение положения регулирующего органа;"\
  eta - &"относительное изменение положения выходной" \ &"координаты элемента сравнения;"\
  zeta_"му" - &"относительное изменение положения" \ &"механизма управления турбиной;"\
  nu_г - &"относительное изменение нагрузки на генераторе."\
$
)

#pagebreak()

Эта система уравнений, подготовленная для анализа средствами DifferentialEquations.jl, записана в функции, приведённой на @list1[листинге].

#figure(
  text(size:12pt)[
```julia
function simulate_system(;
    Ta = 7,
    Tπ = 0.4,
    Ts = 0.7,        
    δω = 0.12,
    ηг = t -> t >= 2 ? -1 : 0.0,
    u0  = [0.0, 0.0, 0.0], 
    tspan = (0.0, 30.0)
)
    function system!(du, u, p, t)
        φ, π, ξ = u
        η = -φ / δω
        du[1] = (π - ηг(t)) / Ta
        du[2] = (ξ - π    ) / Tπ
        du[3] = (η - ξ    ) / Ts
    end

    prob = ODEProblem(system!, u0, tspan)
    solve(prob, Tsit5(), reltol=1e-6, abstol=1e-6)
end
```
  ],
  supplement: [Листинг],
  kind:"listing",
  caption: [Функция, описывающая исследуемую САР],
) <list1>\
#set list(marker: [--])

Рассмотрим @list1[листинг] построчно:
- На строчках 2-9 задаются значения параметров САР $T_a,T_pi,T_c,delta_omega$ согласно выданному варианту, а также закон зависимости внешнего воздействия от времени $nu_г (t)$, начальные условия `u0` и время симуляции;
- На строчках 10-16 описана собственно исследуемая система;
- На строчке 18 из уравнения, начальных условий и времени симуляции формулируется задача `prob` для решателя;
- На строчке 19 происходит решение системы уравнений с помощью выбранного решателя Tsit5() и выбранных коэффициентов для него; Результат  представляет из себя численную зависимость $phi(t)$ для одного режима САР.

#pagebreak()
= Методика исследования

Первым шагом исследования является поиск значений варьируемых параметров, при которых система теряет устойчивость по Ляпунову, то есть не существует $delta(epsilon)$ для любого $epsilon$, при котором все величины $phi_(t>t_0)<=delta(epsilon)$. /* $lim_(t->infinity) phi(t) = phi_infinity$. */ В результате анализа с помощью двухстороннего бинарного поиска получено, что для параметров $T_s,T_pi$ и $delta_omega$ таких значений нет, а критическим значением $T_a$ является $T_a_k=2.125$, что демонстрирует @waw[рисунок], на котором изображено решение системы уравнений на большом промежутке времени. Видно, что это предельное значение, при котором $phi_(t>=t_0)<=delta(epsilon)$, при более высоких значениях $T_a$ каждый следующий пик $phi(t)$ будет выше предыдущего, то есть не будет существовать $delta(epsilon)$, при котором выполняется условие, а значит система не будет устойчива по Ляпунову. /*$lim_(t->infinity) phi(t)$ не существует.*/

#figure(
  image("assets/waw.svg", width: 80%),
  caption: [График зависимости $phi(t)$ от $t$ при $T_a_k=2.125$],
) <waw> \

Таким образом, можно назначить промежутки для варьирования параметров САР. Для $T_s,T_pi$ и $delta_omega$ промежутки произвольного размера назначены симметрично их исходным значениям из соображения наглядности. Для $T_a$ промежуток назначен с учётом $T_a_k$, чтобы продемонстрировать потерю устойчивости системы. Назначенные промежутки указаны в @arr[таблице].

#figure(
  table(
    columns: (1fr,1fr,1fr),
    row-gutter: (1.7pt, auto),
    table.header[Параметр][Исходное значение][Промежуток],
    [$T_a$        ],[$7 c$              ],[$2.125 c$ --- $10 c$ ],
    [$T_pi$       ],[$0.4 c$            ],[$0.4 c$ --- $1 c$    ],
    [$T_s$        ],[$0.7 c$            ],[$0.2 c$ --- $0.6 c$  ],
    [$delta_omega$],[$0.12 %$           ],[$0.08 %$ --- $0.16 %$],
  ),
  caption: [Назначение промежутков варьирования],
  kind: "table",
  supplement: "Таблица"
) <arr>

По итогам варьирования параметров САР и решения системы описывающих её уравнений получены трёхмерные графики в координатах, отражающих зависимость $phi$ от $t$ и варьируемого параметра САР, а также двумерные графики зависимости параметров переходного процесса от варьируемого параметра САР.

Для вычисления установившейся ошибки регулирования $phi_0$ производится визуальная оценка времени переходного процесса по полученным трёхмерным графикам, после чего берётся значение $phi(t)$ при $t$ заведомо больше $t_п$. Ответственная за это функция приведена на @list3[листинге].

#figure(
  text(size:12pt,)[
```julia
function compute_static_errors(solutions)
    static_errors = [sol[1,end] for sol in solutions]
end
```
  ],
  supplement: [Листинг],
  kind:"listing",
  caption: [Функция для вычисления $phi_infinity$],
) <list3>\

Для поиска времени переходного процесса используется функция, приведённая на @list2[листинге]. В ней при обратном ходе по времени происходит поиск значения времени, при котором значение $phi(t)$, отличается от $phi_0$ больше, чем на допуск $5%$.

#figure(
  text(size:12pt,)[
```julia
function find_settling_time(sol, phi_steady; tolerance=0.05)
    times = sol.t
    phi_values = sol[1, :]
    lower = phi_steady * (1 - tolerance)
    upper = phi_steady * (1 + tolerance)
    
    # Идем с конца к началу
    for i in length(phi_values):-1:1
        if !(lower <= phi_values[i] <= upper)
            return i < length(times) ? times[i+1] : times[end]
        end
    end
    return times[1]
end
```
  ],
  supplement: [Листинг],
  kind:"listing",
  caption: [Функция для вычисления $t_п$],
) <list2>\

Для вычисления максимальной динамической ошибки регулирования $phi_max$ используется функция, приведённая на @list4[листинге]. В ней берётся наибольшее по модулю значение $phi$, так как $phi_0=0$.

#figure(
  text(size:12pt,)[
```julia
function compute_dynamic_errors(sol)
    maximum(abs.(sol[1, :]))
end
```
  ],
  supplement: [Листинг],
  kind:"listing",
  caption: [Функция для вычисления $phi_(max)$],
) <list4>\

#pagebreak()
= Результаты численного моделирования

== Варьирование $T_a$

На @Ta[рисунке] изображён трёхмерный график зависимости $phi(t)$ от $T_a$. На @U1[рисунке] изображены графики зависимости $t_п$, $phi_max$ и $phi_infinity$ от $T_a$.

#figure(
  image("assets/surface_plot_Ta.svg", width: 75%),
  caption: [График зависимости $phi(t)$ от $T_a$],
) <Ta>

#figure(
  image("assets/uni_Ta.svg", width: 80%),
  caption: [Графики зависимости $t_п$, $phi_max$ и $phi_infinity$ от $T_a$],
) <U1>

#pagebreak()
== Варьирование $T_pi$

На @Tπ[рисунке] изображён трёхмерный график зависимости $phi(t)$ от $T_pi$. На @U2[рисунке] изображены графики зависимости $t_п$, $phi_max$ и $phi_infinity$ от $T_pi$.

#figure(
  image("assets/surface_plot_Tπ.svg", width: 80%),
  caption: [График зависимости $phi(t)$ от $T_pi$],
) <Tπ>

#figure(
  image("assets/uni_Tπ.svg", width: 80%),
  caption: [Графики зависимости $t_п$, $phi_max$ и $phi_infinity$ от $T_pi$],
) <U2>

#pagebreak()
== Варьирование $T_s$

На @Ts[рисунке] изображён трёхмерный график зависимости $phi(t)$ от $T_s$. На @U3[рисунке] изображены графики зависимости $t_п$, $phi_max$ и $phi_infinity$ от $T_s$.

#figure(
  image("assets/surface_plot_Ts.svg", width: 80%),
  caption: [График зависимости $phi(t)$ от $T_s$],
) <Ts>

#figure(
  image("assets/uni_Ts.svg", width: 80%),
  caption: [Графики зависимости $t_п$, $phi_max$ и $phi_infinity$ от $T_s$],
) <U3>

#pagebreak()
== Варьирование $delta_omega$

На @dw[рисунке] изображён трёхмерный график зависимости $phi(t)$ от $delta_omega$. На @U4[рисунке] изображены графики зависимости $t_п$, $phi_max$ и $phi_infinity$ от $delta_omega$.

#figure(
  image("assets/surface_plot_δω.svg", width: 80%),
  caption: [График зависимости $phi(t)$ от $delta_omega$],
) <dw>

#figure(
  image("assets/uni_δω.svg", width: 80%),
  caption: [Графики зависимости $t_п$, $phi_max$ и $phi_infinity$ от $delta_omega$],
) <U4>

#pagebreak()
= Анализ результатов численного моделирования

Из анализа графиков зависимости времени переходного процесса $t_п$ от варьируемых параметров САР следует, что:
+ Изменение $t_п$ происходит ступенчато, что, как видно из объёмных графиков, связано с "горбами", возникающими при колебаниях и методом определения этой величины, связанной с допуском. Наивысшая точка "горба" находится в его середине, по мере его уменьшения или увеличения сначала проходить допуск будут его крайние точки, но не центр, а с прохождением центра "горба" в допуск в него попадает вся его длина;
+ При увеличении $T_a$ и $delta_omega$ величина времени переходного процесса падает, тогда как при увеличении $T_s$ и $T_pi$ это значение растёт.

\

Из анализа графиков зависимости максимальной динамической ошибки регулирования $phi_max$ от варьируемых параметров САР следует, что:
+ С ростом $T_pi$, $T_s$ и $delta_omega$ значение динамической ошибки регулирования растёт, тогда как с ростом $T_a$ её значение падает;
+ При варьировании $T_pi$, $T_s$ и $delta_omega$ значение максимальной динамической ошибки изменяется линейно, тогда как при варьировании $T_a$ значение изменяется нелинейно. Скорость этого уменьшения уменьшается с ростом $T_a$.

\

Из анализа графиков зависимости статической ошибки регулирования $phi_infinity$ от варьируемых параметров САР следует, что:
+ При варьировании параметров $T_s$ и $T_pi$, а также $T_a$, исключив участок неустойчивости, значение $phi_infinity$ остаётся неизменным и численно равным значению коэффициента обратной связи $delta_omega=0.12$;
+ С ростом $delta_omega$ значение $phi_infinity$ линейно растёт.

#set heading(numbering: none)
#pagebreak()
= Заключение

По итогам проведения численного моделирования изменения параметров переходного процесса при варьировании параметров САР конденсационной паровой турбины без промежуточного перегрева пара получено, что:
- Для уменьшения времени переходного процесса $t_п$ следует увеличивать значения $T_a$ и $delta_omega$ и уменьшать значения $T_s$ и $T_pi$;
- Для уменьшения максимальной динамической ошибки регулирования $phi_max$ следует увеличивать значение $T_a$ и уменьшать значения $T_pi$, $T_s$ и $delta_omega$;
- Для уменьшения статической ошибки регулирования $phi_infinity$ следует уменьшать величину $delta_omega$;
- При уменьшении величины постоянной времени ротора $T_a$ система может потерять устойчивость по Ляпунову.

