﻿Процедура УстановитьПраздничныеДниГодаНаСервере(Регистратор) Экспорт
	
	Запрос = Новый Запрос;
	МВТ =  Новый МенеджерВременныхТаблиц;
	Запрос.МенеджерВременныхТаблиц = МВТ;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ГрафикРаботыПредприятия.ДатаВыходногоДня КАК ДатаВыходногоДня
	|ПОМЕСТИТЬ ВременнаяТЗ
	|ИЗ
	|	РегистрСведений.ГрафикРаботыПредприятия КАК ГрафикРаботыПредприятия
	|ГДЕ
	|	ГрафикРаботыПредприятия.Служебный = ИСТИНА
	|	И ГрафикРаботыПредприятия.Регистратор.Ссылка = &Регистратор";
	// исправляю свою ошибку, так как не понимал, почему код не отрабатывал на другие года
	// благодоря установке параметра ссылки на регисторатор, в запрос попадет только документ
	// который необходим, без лишних дат, и лет, и код нормально отработает.
	Запрос.УстановитьПараметр("Регистратор",Регистратор);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	// этот кусок кода нужно переделать, так как, мне казалось, что все гораздо сложнее с изменением
	// записи. Да и вообще бредовая была идея таким образом перебирать нужные мне даты.
	// МВТ оказался просто не нужен, в данном коде просто достаточно будет считать поле регистратор
	// один раз.
	
	Запрос2 = Новый Запрос;
	Запрос2.Текст =   "ВЫБРАТЬ
	|	ГрафикРаботыПредприятия.Регистратор КАК Регистратор
	|ИЗ
	|	ВременнаяТЗ КАК МВТ,
	|	РегистрСведений.ГрафикРаботыПредприятия КАК ГрафикРаботыПредприятия
	|ГДЕ
	|	МВТ.ДатаВыходногоДня = ГрафикРаботыПредприятия.Дата";
	
	Запрос2.МенеджерВременныхТаблиц = МВТ;
	РезультатЗапроса = Запрос2.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();
	
	
	// САМОЕ ИНТЕРЕСНОЕ. 
	// Создаю набор записи, устанавливаю отбор по регистратору, я до этого не знал, что набор записей
	// это таблица значений, которую можно просто перебрать и установить нужные значения.
	// и начал городить полный костыль, хотя решение было настолько близко, что я даже не ожидал.
	НаборЗаписей = РегистрыСведений.ГрафикРаботыПредприятия.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Регистратор.Установить(ВыборкаДетальныеЗаписи.Регистратор);   
	НаборЗаписей.Прочитать();
	
	// Этот запрос обращается к реквизиту Служебный, который был обьявлен для удобства
	// и считывает дату с реквизита ДатаВыходногоДня, который обозначен как 
	// Дата понедельника следующей недели, после чего результат запроса выгружается в массив
	Запрос3 = Новый Запрос;
	Запрос3.Текст = 
	"ВЫБРАТЬ
	|	ГрафикРаботыПредприятия.ДатаВыходногоДня КАК ДатаВыходногоДня
	|ИЗ
	|	РегистрСведений.ГрафикРаботыПредприятия КАК ГрафикРаботыПредприятия
	|ГДЕ
	|	ГрафикРаботыПредприятия.Служебный = ИСТИНА";
	
	МассивНерабочихДат = Запрос3.Выполнить().Выгрузить().ВыгрузитьКолонку("ДатаВыходногоДня");
	
	// Тут все предельно просто, идет сопоставление дат из МассиваНерабочихДней, а так как 
	// реквизит хранил дату дня, который нужно сделать нерабочим, то цикл просто перебирается
	// а при обнаружении совпадений перезаписываем записи в регистр сведений
	Для Каждого Запись ИЗ НаборЗаписей Цикл
		
		Для Каждого НерабочаяДата ИЗ МассивНерабочихДат Цикл
			
			Если Запись.Дата = НерабочаяДата Тогда
				
				Запись.День = 0;
				Запись.ВремяНачалаРаботы = 0;
				Запись.ВремяОкончанияРаботы = 0;
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	// записываем уже окончательные данные
	//  так же флаг в ИСТИНА, чтобы значения заменялись.
	НаборЗаписей.Записать(ИСТИНА);		
	
КонецПроцедуры