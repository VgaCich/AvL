unit AvlICQLang;
{************************************************
    For updates checkout: http://www.cobans.net
      (C) Alex Demchenko(alex@ritlabs.com)
          Gene Reeves(notgiven2k@lycos.com)
*************************************************}


interface
type
  TICQLangType = (
    LANG_EN {English}, 
    LANG_RU {Russian}
    {Add new language identifiers here}
  );

  TTranslateFunction = function(ResID: LongWord): String;
  TICQLangNode = record
    Lang: TICQLangType;
    Translate: TTranslateFunction;
  end;

  function LangEn(ResID: LongWord): String;
  function LangRu(ResID: LongWord): String;
  {Add new translate-functions here}

const
  ICQLanguages: array[Low(TICQLangType)..High(TICQLangType)] of TICQLangNode = (
    (Lang: LANG_EN; Translate: LangEn),
    (Lang: LANG_RU; Translate: LangRu)
    {Add new lines here}
  );


  {Resource string identifiers, do not modify}
  IMSG_BASE                     = 0;
  IMSG_EPROTO_LEN               = IMSG_BASE + 1;
  IMSG_EHTTP_INIT               = IMSG_BASE + 2;
  IMSG_EMALFORMED_PKT           = IMSG_BASE + 3;
  IMSG_WADD_USER                = IMSG_BASE + 4;
  IMSG_EMALFORMED_LOGIN_PKT     = IMSG_BASE + 5;
  IMSG_EBAD_PASS                = IMSG_BASE + 6;
  IMSG_EOFTEN_LOGINS            = IMSG_BASE + 7;
  IMSG_WDC_BAD_PROXY            = IMSG_BASE + 8;
  IMSG_ECON_TIMEDOUT            = IMSG_BASE + 9;
  IMSG_ESOCK_SEND               = IMSG_BASE + 10;
  IMSG_ESOCK_RESOLVE            = IMSG_BASE + 11;
  IMSG_ESOCK_CONNECT            = IMSG_BASE + 12;
  IMSG_ESOCK_RECV               = IMSG_BASE + 13;
  IMSG_ESOCK_SOCKET             = IMSG_BASE + 14;
  IMSG_ESOCK_SOCKS4CONN         = IMSG_BASE + 15;
  IMSG_ESOCK_SOCKS5AUTH         = IMSG_BASE + 16;
  IMSG_ESOCK_SOCKS5NA           = IMSG_BASE + 17;
  IMSG_ESOCK_SOCKS5CONN         = IMSG_BASE + 18;
  IMSG_ESOCK_HTTPSTAT           = IMSG_BASE + 19;
  IMSG_ESOCK_HTTPBUF            = IMSG_BASE + 20;
  IMSG_ESOCK_ACCEPT             = IMSG_BASE + 21;
  IMSG_ESOCK_BIND               = IMSG_BASE + 22;
  IMSG_ESOCK_LISTEN             = IMSG_BASE + 23;
  IMSG_EDB_EFILEOPEN            = IMSG_BASE + 24;
  IMSG_EDB_EDBVERNOTSUPPORTED   = IMSG_BASE + 25;





implementation

  function LangEn(ResID: LongWord): String;
  begin
    case ResID of
      {ICQClient}
      IMSG_EPROTO_LEN:                  Result := 'Length of incoming packet exceeds maximum supported by protocol';
      IMSG_EHTTP_INIT:                  Result := 'Could not initialize connection through HTTP proxy, please retry';
      IMSG_EMALFORMED_PKT:              Result := 'Received malformed packet';
      IMSG_WADD_USER:                   Result := 'Could not add user for sending/receiving files';
      IMSG_EMALFORMED_LOGIN_PKT:        Result := 'Received malformed login packet';
      IMSG_EBAD_PASS:                   Result := 'Bad password';
      IMSG_EOFTEN_LOGINS:               Result := 'Too often logins';
      IMSG_WDC_BAD_PROXY:               Result := 'Cannot estabilish direct connection because remote client uses unknown proxy type';
      IMSG_ECON_TIMEDOUT:               Result := 'Connection timed out';
      {ICQSock}
      IMSG_ESOCK_SEND:                  Result := 'Could not send data';
      IMSG_ESOCK_RESOLVE:               Result := 'Could not resolve host';
      IMSG_ESOCK_CONNECT:               Result := 'Could not connect';
      IMSG_ESOCK_RECV:                  Result := 'Could not receive data';
      IMSG_ESOCK_SOCKET:                Result := 'Could not create stream socket';
      IMSG_ESOCK_SOCKS4CONN:            Result := 'SOCKS4 server cannot connect to remote server';
      IMSG_ESOCK_SOCKS5AUTH:            Result := 'Auth methods are not supported by SOCKS5 server';
      IMSG_ESOCK_SOCKS5NA:              Result := 'SOCKS5 server cannot authenticate';
      IMSG_ESOCK_SOCKS5CONN:            Result := 'SOCKS5 server cannot connect to remote server';
      IMSG_ESOCK_HTTPSTAT:              Result := 'Http proxy returned invalid status: ';
      IMSG_ESOCK_HTTPBUF:               Result := 'Http proxy buffer overflow';
      IMSG_ESOCK_ACCEPT:                Result := 'Coult not accept incoming client';
      IMSG_ESOCK_BIND:                  Result := 'Could not bind server';
      IMSG_ESOCK_LISTEN:                Result := 'Could not listen incoming connections';
      {ICQDb}      
      IMSG_EDB_EFILEOPEN:               Result := 'Could not open database files';
      IMSG_EDB_EDBVERNOTSUPPORTED:      Result := 'Dat version not supported';
    else
      Result := '';
    end;
  end;

  function LangRu(ResID: LongWord): String;
  begin
    case ResID of
      {ICQClient}
      IMSG_EPROTO_LEN:                  Result := 'Размер входящего пакета превышает максимально допустимое значение';
      IMSG_EHTTP_INIT:                  Result := 'Невозможно инициализоваровать подключение через HTTP прокси, пожалуйста повторите';
      IMSG_EMALFORMED_PKT:              Result := 'Получен неверно сформированный сетевой пакет';
      IMSG_WADD_USER:                   Result := 'Невозможно добавить пользователя для посылки/приема файлов';
      IMSG_EMALFORMED_LOGIN_PKT:        Result := 'Получен неверно сформированный login пакет';
      IMSG_EBAD_PASS:                   Result := 'Неверный пароль';
      IMSG_EOFTEN_LOGINS:               Result := 'Вход в сеть ICQ происходит слишком часто, подождите 10 минут';
      IMSG_WDC_BAD_PROXY:               Result := 'Невозможно установить прямое подключение, т.к. тип прокси пользователя неизвестен';
      IMSG_ECON_TIMEDOUT:               Result := 'Время подключения истекло';
      {ICQSock}
      IMSG_ESOCK_SEND:                  Result := 'Невозможно отослать информацию';
      IMSG_ESOCK_RESOLVE:               Result := 'Невозможно получить IP хоста';
      IMSG_ESOCK_CONNECT:               Result := 'Невозможно подключиться';
      IMSG_ESOCK_RECV:                  Result := 'Невозможно получить информацию';
      IMSG_ESOCK_SOCKET:                Result := 'Невозможно создать сокет';
      IMSG_ESOCK_SOCKS4CONN:            Result := 'SOCKS4 прокси не может соединиться с удаленным сервером';
      IMSG_ESOCK_SOCKS5AUTH:            Result := 'На SOCKS5 прокси сервере не найдены подходящие методы аторизации';
      IMSG_ESOCK_SOCKS5NA:              Result := 'SOCKS5 прокси не может авторизовать пользователя';
      IMSG_ESOCK_SOCKS5CONN:            Result := 'SOCKS5 прокси не может соединиться с удаленным сервером';
      IMSG_ESOCK_HTTPSTAT:              Result := 'HTTP прокси вернула неверный статус: ';
      IMSG_ESOCK_HTTPBUF:               Result := 'Переполнение буффера HTTP';
      IMSG_ESOCK_ACCEPT:                Result := 'Невозможно выполнить функцию Accept';
      IMSG_ESOCK_BIND:                  Result := 'Невозможно запустить сервер';
      IMSG_ESOCK_LISTEN:                Result := 'Невозможно установить сокет в статус ожидания соединений';
      {ICQDb}
      IMSG_EDB_EFILEOPEN:               Result := 'Невозможно открыть базу данных';
      IMSG_EDB_EDBVERNOTSUPPORTED:      Result := 'Версия базы данных не поддерживается';
    else
      {If we cannot translate, return the english version of the string}
      Result := ICQLanguages[LANG_EN].Translate(ResID);
    end;
  end;

end.