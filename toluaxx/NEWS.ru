2007-08-24:
	Поправил автоматическую генерацию конструктора и деструктора (опция --auto-gen). Генерацию sizeof функции (оператор~) по некоторым соображениям запретил.

	Добавил еще две функции тестирования:
	one_of     | oneof    | oo - один из
	not_one_of | notoneof | no - ниодин из

	Разработал средства отслеживания созданных объектов и объектных сред.
	Все созданные объекты находятся в псевдотаблице tolua.watch.object, а среды в tolua.watch.objenv, объекты сохраняются как ключи, все значения пока true, в дальнейшем там будет сохраняться информация о существующем объекте.
	Оператор # может быть использован для получения их общего числа. По этим таблица можно делать итерацию, и обращаться по индексу.


2007-08-23:
	Добавлена директива $arg строка аргументов, позволяющая прописываь в .pxx файле аргументы командной строки, иногда это крайне удобно, позволяет сократить список аргументов, используемых при вызове toluaxx до одного или нескольких имен входных файлов. Следует учесть, что аргументы, объявленные в самом файле этой директивой, заменяют установленные из командной строки, если они с ними конфликтуют. Также не все параметры можно установить таким образом, только те, что конфигурируют обработчик. Параметры вроде --help, -i и подобные, служащие для других целей, будучи переданными здесь, игнорируются. Не важно, в каких местах использована эта директива, все объявленные таким образом аргументы будут применены последовательно до начала обработки входного файла.
	Примеры использования:
	
	положим у нас есть файл probe.pxx который нужно обработать, при этом следует создать файл probe.bind.cxx для компиляции и включить автоматическое создание конструкторов и деструкторов для классов, а также создать прототип функции main в этом файле.
	
	----probe.pxx------------------------------------------
	$arg --auto-gen --main-gen -o probe.bind.cxx
	....
	-------------------------------------------------------

	запускаем:

	:-] toluaxx probe.pxx

	В связи с тем, что автор шибко увлекся такими вещами, как doxygen, вид специального комментария, который делает видимым для toluaxx код, скрываемый от компилятора C/C++, претерпел некоторые изменения. Нотация: /** hidden code **/ заменена на /*$ hidden code $*/. Если вы уже использовали этот комментарий в своих проектах, используйте продвинутые функциии замещения текста в вашем редакторе. (т.к. я использую GNU Emacs, в исходных кодах своих проектов сделать это было достаточно просто, например для однострочных вхождений: M-x replace-regexp RET /\*\*\([^\*\*/]*\)\*\*/ RET /*$\1$*/)
	
	Поправил скрытие областей видимости классов.

	Полностью переписал систему тестирования, отладил поддержку методов тестирования. Также пользователю предоставляется возможность использовать объявленные им методы.
	Метод тестирования представляет собой Lua или C функцию, принимающую два аргумента, первым из которых является полученное значение тестируемой величины, второй аргумент - ожидаемое значение этой величины, второй аргумент может быть чем угодно, пользователь может использовать его по своему усмотрению. Этот метод выполняет проверку адекватности результата, то есть полученной в тестовом проходе величины путем сравнения с неким критерием, называемым ожидаемым значением. Эта функция должна вернуть одно значение: true в случае, если проверка прошла и полученное значение адекватно критерию ожиданния, в противном случае функция должна вернуть два значения: false и "сообщение об ошибке".
	Функция проверки представляет собой утверждение, если оно выполняется - проверка прошла.
	Также существенно расширил список предопределенных функций проверки:

	type_not_is | tni | ni            - тип полученного значения должен быть отличен от ожидаемого
	type_is | ti                      - тип полученного значения должен быть равен ожидаемому

	type_not_equal | tneq | tne | tn  - типы полученного и ожидаемого значений не должны совпадают
	type_equal | teq | te             - типы полученного и ожидаемого значений должны совпадать

	not_equal | neq | ne              - полученное и ожидаемое значения не должны совпадать
	equal | eq                        - полученное и ожидаемое значения должны совпадать

	lesser_than | lessthan | lt       - полученное значение должно быть строго меньше ожидаемого
	lesser_equal | lessequal | le     - полученное значение должно быть меньше либо равно ожидаемому

	greater_than | greatthan | gt     - полученное значение должно быть строго больше ожидаемого
	greater_equal | greatequal | ge   - полученное значение должно быть больше либо равно ожидаемому

	between | bw                      - полученное значение должно быть между двумя ожидаемыми, но не равно ни одному из них
	onto | on                         - полученное значение должно быть между двумя ожидаемыми или равно одному из них
	       	(прим. при использовании этих методов передается два значения в виде таблицы, например:
	     	    	t=tolua.test()
			t(2,{1,3},t.bw,"2 больше 1, но меньше 3")
		    )

	string_not_equal | strneq | sn    - полученное значение в виде строки не должно совпадать с ожидаемым
	string_equal | streq | se         - полученное значение в виде строки должно совпадать с ожидаемым
		(прим. в этих методах используется метод приведения типа tostring, оба значения приводятся к строчному представлению и сравниваются)


2007-08-22:
	Добавление к системе тестирования возможности выбирать способ проверки адекватности принимаемого значения. Аргумент передается третьим, сразу после получаемого и ожидаемого, но перед описанием прохода теста. Возможные варианты проверки:
	t.equal         | t.eq  - равенство значений
	t.not_equal     | t.ne  - неравенство значений
	t.type_equal    | t.teq - равенство типов (проверять только равны ли типы)
	t.lesser_than   | t.lt  - получаемое значение должно быть меньше ожидаемого
	t.lesser_equal  | t.le  - получаемое значение должно быть меньше или равно ожидаемому
	t.greater_than  | t.gt  - получаемое значение должно быть больше ожидаемого
	t.greater_equal | t.ge  - получаемое значение должно быть больше или равно ожидаемому

2007-08-07:
	Реализована встроенная система тестирования, она чрезвычайно проста,
	позволяет тестировать на соответствие типов и значений получаемого
	и ожидаемого. Также по завершению тестирования позволяет формировать
	информацию о результатах в расширенной форме с возможностью выдачи
	информации о возникших ошибках, соотношение числа выполненных и общего
	числа запущенных на выполнение тестов, а также общего процента выполнения.

	Работа с системой осуществляется следущим образом:

	-- 1. Для начала создаем модуль тестирования
	local t=tolua.test("имя модуля", "описание тестов", "автор тестов")
	-- 2. Производим серию тестов на соответствие пулучаемого значения
	--    ожидаемому.
	t(получаемое значение 1, ожидаемое значение 1, "описание прохода 1")
	....
	t(получаемое значение N, ожидаемое значение N, "описание прохода N")
	-- 3. Получаем информацию о результатах.
	print(t)

	Так как встроенная система тестирования теперь используется в тестах,
	подробности могут быть найдены в src/tests, а именно врапер base.lua.

	Подробнее о методах и свойствах объекта модуля тестирования:
	t:assert(получаемое значение, ожидаемое значение, "описание прохода")
	               -- то же что и t(....), осуществляет тестовый проход
	t.name         -- имя модуля тестов
	t.author       -- автор модуля тестов
	t.description  -- описание модуля тестов
	#t,t.count     -- общее число запущенных тестов
	t(),t.passed   -- число тестов, выполненных успешно
	t.progress     -- % успешности выполнения
	t.state        -- true если все тесты пройдены успешно
	t.report       -- полный отчет о прохождении тестов, включая
		       -- информацию о всех возникших ошибках
	t.result       -- только отчет о выполнении, без ошибок
	t.errors       -- только отчет о возникших ошибках
	t[номер теста] -- доступ к каждому результату теста по отдельности,
	               -- номер теста должен быть числом от 1 до #t
	t[номер теста].description    -- описание тестового прохода
	t[номер теста].received       -- переданное значение
	t[номер теста].expected       -- ожидаемое  значение
	t[номер теста].state          -- успешность тестового прохода
	t[номер теста].message        -- сообщение об ошибке тестового прохода
				      	 если проход успешен, примет значение nil


2007-07-30:
	Релицензирование. Поздравьте, теперь мы окончательно перешли на GPLv3,
	огромное спасибо Ричарду Столлману, а также всем тем, кто принимал
	участие в разработке новой версии свободной лицензии на программное
	обеспечение.


2007-07-25:
	Багфикс extract_code. Добавлена опция командной строки -I, аналогичная
	таковой в лучшем свободном компиляторе GCC, позволяет добавлять пути
	поиска включаемых файлов к путям по умолчанию.


2007-07-24:
	Создана новая система передачи параметров командной строки, поддерживающая
	встроенное их документирование, что избавляет от излишек кода и позволяет
	исключить разного рода неоднозначности.


2007-07-23:
	Было решено отказаться от использования C++ для toluaxx. Все переписано
	полностью на lua. Все собирается с помощью компилятора luac в один toluaxx
	файл, который можно исполнить вызовом lua toluaxx аргументы биндера, или
	в юниксе просто вызвать toluaxx аргументы, так как первой строкой в нем
	является #!/usr/bin/env lua5.1 и при установке ему даются права на
	выполнение. Пока не решено, как реализовать его использование на не юникс
	платформах, конечно вызов lua toluaxx аргументы меня, как разработчика
	вполне бы устроил, но пользователи могут не понять.


2007-07-20:
	Появилась новая возможность создавать файл бинда, который имеет собственную
	функцию main и может быть собран в исполняемый файл. Задействование этой
	возможности осуществляется с помощью параметра -m|--main-gen.


2007-01-14:
	После преодоления всех тягостей студенческой жизни снова возвращаемся
	к нашей не простой, но очень интересной работе. toluaxx уже достаточно
	стабильно работает и пригоден к использованию в проекте lunique, но
	до сих пор остаются некоторые вещи, требующие доработки. К чему,
	собственно, мы и приступим.
	Табличный инициализатор работает теперь и на ранее созданных объектах.
	Например так:
	
	local o=OBJ()
	o{
	  prop1=value1,
	  ....,
	  propN=valueN
	}


2006-11-15:
	Реализован табличный конструктор объекта. Теперь можно передать
	Таблицу параметров объекта в конструктор последним или
	единственным аргументом.

	Например:

	-------tolua-table-constructor.hxx----------
	class TCLASS{
	....
	  struct TPARAM{
	    int value;
	    string name;
	  };
	....
	  TPARAM param;
	  int value;
	  string name;
	....
	  TCLASS();
	....
	};

	-------tolua-table-constructor.lua----------
	local t=TCLASS{
	   name="newopt",
	   param={
	      name="newsubopt",
	      value=12
	   },
	   value=0.12
	}
	

2006-11-14:
	Добавлена технология передачи параметров через стек-посредник.
	Стек состоит из нумерованых уровней от 1 до N. Каждый уровень
	может содержать один или несколько поименованных параметров.
	Положительные индексы уровня стека при обращении указывают на
	реальный уровень с первого. Отрицательные индексы определяют
	уровни стека от вершины. Текущая вершина стека больше 0, если
	стек не пуст и равна нулю иначе.

	Функции toluaxx API для работы со стеком параметров:

	int  tolua_proxytop(lua_State* L);
	/* возвращает текущую вершину стека параметров */
	
	int  tolua_proxypush(lua_State* L);
	/* инициирует новый пустой уровень стека параметров */
	
	int  tolua_proxypop(lua_State* L);
	/* утилизирует верхний уровень стека параметров */
	
	void tolua_proxylevel(lua_State* L, int level);
	/* извлекает запрошенный уровень стека как таблицу */
						
	void tolua_getproxy(lua_State* L, int level);
	/* извлекает значение параметра из запрошенного уровня стека */
	/* (действует подобно lua_gettable()) */
	
	void tolua_setproxy(lua_State* L, int level);
	/* устанавливает значение параметра в запрошенный уровень стека */
	/* (действует подобно lua_settable()) */

	Функции toluaxx proxy, доступные из lua:

	local top = tolua.proxy.top()
	-- извлечение текущего размера стека
	-- top установится равным текущему размеру стека параметров

	local level = tolua.proxy.level(<level>)
	-- извлечение уровня стека (по умолчанию верхнего)
	-- level будет ссылаться на таблицу параметров выбранного
	-- уровня стека

	local state = tolua.proxy.push()
	-- создание нового верхнего уровня стека
	-- state - будет true если новый урвень стека создан
	-- false - если стек переполнен

	local state = tolua.proxy.pop()
	-- удаление текущего верхнего уровня стека
	-- state - будет true если текущий урвень стека удален
	-- false - если стек пуст

	local val = tolua.proxy.get(key<,level>)
	-- извлечение параметра с именем key из уровня стека
	-- level (по умолчанию из верхнего)
	-- val установится в значение параметра, если параметра нет
	-- в nil

	tolua.proxy.set(key,value<,level>)
	-- установка параметра с именем key и значением value
	-- в уровень стека level (по умолчанию в верхний)

	Пример работы продемонстрирован в toluaxx/src/test/tproxy.*
	

2006-11-13:
	Исправлен экспорт массивов, находящихся в пространствах имен.
	

2006-11-10:
	Добавлены директивы tolua_getindex { } и tolua_setindex { }.
	В первую заключаются функции извлечения индекса (то есть те,
	что будут вызваны в метаметоде __index). Во вторую - финкции
	установки индекса (что будут вызваны в метаметоде __newindex).
	Обе директивы позволяют специфицировать методы доступа
	`.{get,set}{i,s}`.

	Например:
	
	-------tolua-get-set-index.hxx-------
	class TOBJECT{
	....
	};
	class TGROUP: public TOBJECT{
	  /**tolua_getindex {**/
	  TOBJ* get(string);
	  /**}**/
	  /**tolua_setindex {**/
	  void set(string,TOBJ*);
	  /**}**/
	....
	};
		
	-------tolua-index-test.lua----------
	local g1=TGROUP()
	g1.o1=TOBJECT()  --- срабатывает set метод
	local o1=g1.o1    --- вызывается get метод

	
2006-10-24:
	Чтобы garbage collector не удалял userdata, добавленные
	в объект методами .set{i,s}, организовал их внесение в
	peer.
	
	Суть решенной проблемы:
	
	local g1=GRP()
	local o1=OBJ()
	
	g1.o1=o1
	collectgarbage"collect" --- объект o1 не удаляется,
				--- ссылка еще существует
				--- в локальной среде
	
	g1.o2=OBJ()
	collectgarbage"collect" --- объект g1.o2 удалится
				--- он был создан в луа и
				--- ссылки на него нигде нет
	--- этот фикс решает проблему (ссылка на объект помещается
	--- в peer g1, не давая garbage collector удалить его)

	
2006-10-23:
	Специальный комментарий `/**`бинд_код`**/` делает заключаемый в него
	код экспорта невидимым для C/C++ компилятора, но видимым для toluaxx
	препроцессора, теперь весь код экспорта можно помещать в заголовочные
	файлы.

	
2006-10-04:
	Добавил спецификатор значения по умолчанию asnil. Теперь
	специфицированные так переменные будут интерпретированы
	как nil, если они равны значению по умолчанию.

	Например:
	------asnil-test.hxx----------------
	class TCLASS{
	       ....
	 public:
	  string menu;
	  void item(string&name){
	    int p,s;
	    if((p=menu.find(name+":"))<menu.length()){
	      p=p+name.length()+1;
	      s=menu.find(" ",p);
	      name=menu.substr(p,s-p);
	    }else name="";
	  }
	};
	------asnil-test.pxx----------------
	class TCLASS{
	       ....
	 public:
	  string menu;
	  void item(string&name="" asnil);
	};
	------asnil-test.lua----------------
	require"asnil-test"
	local t=TCLASS()
	t.menu="first:call second:of third:cthulhu"
	assert(t:item("first")=="call")
	assert(t:item("second")=="of")
	assert(t:item("third")=="cthulhu")
	assert(t:item("fourth")==nil)

	Это весьма полезно использовать в итераторе (операция `()`)
	(пример в src/tests/*index.*)
	

	Также исправлен баг со вставкой имени включаемого файла #include"".
	

2006-10-03:
	Добавил макрос tolua_callmethod(class_name,method_name,arguments,
	num_of_returns,returns), позволяющий вызывать метод класса, в 
	качестве которого может выступать функция объявленная в lua.
	В качестве класса используется `this`.

	Например:
	------call-method-test.hxx----------
	class TCLASS{
	 public:
	  float delta;
	  float time;
	       ....
	  void make(float period){
	    tolua_callmethod(TCLASS,handler,
	      tolua_pushnumber(L,time);
	      tolua_pushnumber(L,period),
	      1,
	      time=tolua_tonumber(L,1)
	    );
	  }
	};
	------call-method-test.lua----------
	require"call-method-test"
	local t=TCLASS()
	function t:handler(time,period)
	   time=time+period
	   self.delta=self.delta+period
	   return time
	end

	t:make(10)
	

2006-09-02:
	Исправлен баг с поиском включаемых методами ${i,l,h,c}file"" файлов.
	Теперь файлы ищутся сначала в директории, откуда запущен препроцессор,
	затем в директории, где расположен обрабатываемый файл.

	
2006-09-29:
	Теперь индексация (оператор `[]`) работает и для строк в качестве
	ключей. Используется метод `__{index,newindex}\\.{get,set}s`.

	Исправлен баг с обявлением переменных в namespace-ах, теперь все
	работает. (!Пока поддерживаются невложенные namespace!)
	
	
2006-09-28:
	Добавил оператор:
	`()` (__call\\.callself) - вызов себя. Его планируется использовать
	в качестве итератора. (пример в src/tests/*index.*)

	
2006-09-27:
	Добавил возможность объявления унарных операторов, таких как:
	`-` (__unm\\.unm) - унарный минус (C++ эквивалент `-`)
	`#` (__len\\.len) - оператор длины (в качестве эквивалента в 
	                    C++ принят `~`)

2006-09-26:
	Создана универсальная кроссплатформенная система сборки на базе Makefile,
	интерпретируемых утилитой GNU Make.
	Для требуемой ОС платформы и соллекции компиляторов создается свой
	конфигурационный файл `config.$(PLATFORM)-$(COMPILER)` и пользовательский
	конфигурационный файл `config.$(PLATFORM)-$(COMPILER).local`.
	В файле `config` указываются переменные конфигурации сборщика, такие как:
	  MODE=test|real            # режим работы сборщика
	  DEBUG=enable|disable      # режим отладки
	  PATH=/usr|....            # путь установки
	  PLATFORM=lunix|win32|.... # платформа
	  COMPILER=gcc|msvs|....    # компилятор
	  .....
	(подробности в руководстве по сборке и в комментариях `config` файла.)

	Сборщик анализирует конфигурационные файлы модулей, находящиеся в
	поддиректориях `src`, и на основе этих данных генерирует зависимости,
	цели сборки и их команды.
	
	Cборка производится командой:
	[shell:]# make all
	установка:
	[shell:]# make install
	удаление:
	[shell:]# make uninstall
	
	
2006-09-25:
	Добавил операторы lua5.1, такие как:
	`^`  (__pow\\.pow)       - возведение в степень (C++ эквивалент `^`)
	`..` (__concat\\.concat) - склеивание (в C++ в качестве эквивалента
	                           взята операция поразрядного или `|`)
	``

2006-09-21:
	Полностью переписал C код src/bin на C++. Теперь последовательность
	аргументов совершенно произвольная.
