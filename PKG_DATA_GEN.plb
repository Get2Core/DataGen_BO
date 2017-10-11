CREATE OR REPLACE PACKAGE PKG_DATA_GEN
IS
  PROCEDURE SHOW_DEMO;
  PROCEDURE DROP_CONST(i_table_name in varchar2 default 'ALL');
  PROCEDURE CRE_CONST;
  PROCEDURE DEL_TABLES;
  PROCEDURE CRE_CATEGORIES;
  PROCEDURE CRE_CORPORATIONS(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE CRE_PRODUCTS(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE CRE_CUSTOMERS(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE CRE_DEPARTMENTS;
  PROCEDURE CRE_EMPLOYEES(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE CRE_SHIPMENT_ADDRESSES(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE CRE_CUST_CONTACTS(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE CRE_ORDERS(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE CRE_ORDER_ITEMS(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE CRE_SHIPMENTS(i_seed_val in NUMBER);
  FUNCTION CRE_HAN_STRING(i_min_string_size in number,i_max_string_size in number,i_type in varchar2) RETURN VARCHAR2;    --i_type : '1':질의응답, '2':사람이름
  PROCEDURE CRE_INQUIRIES(i_seed_val in NUMBER,i_volume in NUMBER);
  PROCEDURE MAIN(i_seed_val in NUMBER,i_volume in NUMBER);
END PKG_DATA_GEN;
/

CREATE OR REPLACE PACKAGE BODY PKG_DATA_GEN
IS
  TYPE rec_han_char IS RECORD (
    hchar varchar2(3)
    ,weight_val NUMBER(2)
  );
  TYPE tab_han_char IS TABLE OF rec_han_char INDEX BY pls_integer;
  g_han_char tab_han_char;

  TYPE rec_han_char_w IS RECORD (
    hchar varchar2(3)
  );
  TYPE tab_han_char_w IS TABLE OF rec_han_char_w INDEX BY pls_integer;
  g_han_char_w tab_han_char_w;    --성으로 사용할 대상
  g_han_char_o tab_han_char_w;    --이름으로 사용할 대상

  g_weighted_char_counter number;   --가중치를 부여한 성 Character 순번
  g_ordinary_char_counter number;   --일반 이름 Charater 수

  g_seed_val  number;

  PROCEDURE SHOW_DEMO
  IS
    v_name          varchar2(40);
  BEGIN
    dbms_random.seed(1234567890);

    FOR i IN 1..30 LOOP
      v_name:=g_han_char_w(ceil(dbms_random.value*g_weighted_char_counter)).hchar||g_han_char_o(ceil(dbms_random.value*g_ordinary_char_counter)).hchar||g_han_char_o(ceil(dbms_random.value*g_ordinary_char_counter)).hchar;
      DBMS_OUTPUT.PUT_LINE(v_name);
    END LOOP;

  END SHOW_DEMO;

  PROCEDURE initialize
  IS
    v_temp_counter  number; --계수를 위한 임시 카운터
  BEGIN
     g_han_char(1).hchar:='강';
     g_han_char(1).weight_val:=6;
     g_han_char(2).hchar:='고';
     g_han_char(2).weight_val:=2;
     g_han_char(3).hchar:='구';
     g_han_char(3).weight_val:=4;
     g_han_char(4).hchar:='국';
     g_han_char(4).weight_val:=1;
     g_han_char(5).hchar:='금';
     g_han_char(5).weight_val:=1;
     g_han_char(6).hchar:='기';
     g_han_char(6).weight_val:=1;
     g_han_char(7).hchar:='길';
     g_han_char(7).weight_val:=1;
     g_han_char(8).hchar:='김';
     g_han_char(8).weight_val:=15;
     g_han_char(9).hchar:='나';
     g_han_char(9).weight_val:=2;
     g_han_char(10).hchar:='노';
     g_han_char(10).weight_val:=2;
     g_han_char(11).hchar:='도';
     g_han_char(11).weight_val:=1;
     g_han_char(12).hchar:='마';
     g_han_char(12).weight_val:=1;
     g_han_char(13).hchar:='모';
     g_han_char(13).weight_val:=1;
     g_han_char(14).hchar:='민';
     g_han_char(14).weight_val:=1;
     g_han_char(15).hchar:='박';
     g_han_char(15).weight_val:=8;
     g_han_char(16).hchar:='반';
     g_han_char(16).weight_val:=1;
     g_han_char(17).hchar:='방';
     g_han_char(17).weight_val:=1;
     g_han_char(18).hchar:='배';
     g_han_char(18).weight_val:=1;
     g_han_char(19).hchar:='백';
     g_han_char(19).weight_val:=4;
     g_han_char(20).hchar:='사';
     g_han_char(20).weight_val:=1;
     g_han_char(21).hchar:='서';
     g_han_char(21).weight_val:=2;
     g_han_char(22).hchar:='선';
     g_han_char(22).weight_val:=1;
     g_han_char(23).hchar:='성';
     g_han_char(23).weight_val:=1;
     g_han_char(24).hchar:='소';
     g_han_char(24).weight_val:=1;
     g_han_char(25).hchar:='손';
     g_han_char(25).weight_val:=4;
     g_han_char(26).hchar:='송';
     g_han_char(26).weight_val:=2;
     g_han_char(27).hchar:='신';
     g_han_char(27).weight_val:=1;
     g_han_char(28).hchar:='안';
     g_han_char(28).weight_val:=4;
     g_han_char(29).hchar:='연';
     g_han_char(29).weight_val:=1;
     g_han_char(30).hchar:='염';
     g_han_char(30).weight_val:=1;
     g_han_char(31).hchar:='오';
     g_han_char(31).weight_val:=2;
     g_han_char(32).hchar:='우';
     g_han_char(32).weight_val:=1;
     g_han_char(33).hchar:='위';
     g_han_char(33).weight_val:=1;
     g_han_char(34).hchar:='유';
     g_han_char(34).weight_val:=5;
     g_han_char(35).hchar:='윤';
     g_han_char(35).weight_val:=4;
     g_han_char(36).hchar:='음';
     g_han_char(36).weight_val:=1;
     g_han_char(37).hchar:='이';
     g_han_char(37).weight_val:=12;
     g_han_char(38).hchar:='전';
     g_han_char(38).weight_val:=3;
     g_han_char(39).hchar:='정';
     g_han_char(39).weight_val:=3;
     g_han_char(40).hchar:='조';
     g_han_char(40).weight_val:=3;
     g_han_char(41).hchar:='주';
     g_han_char(41).weight_val:=3;
     g_han_char(42).hchar:='지';
     g_han_char(42).weight_val:=1;
     g_han_char(43).hchar:='진';
     g_han_char(43).weight_val:=1;
     g_han_char(44).hchar:='채';
     g_han_char(44).weight_val:=1;
     g_han_char(45).hchar:='최';
     g_han_char(45).weight_val:=8;
     g_han_char(46).hchar:='추';
     g_han_char(46).weight_val:=1;
     g_han_char(47).hchar:='하';
     g_han_char(47).weight_val:=3;
     g_han_char(48).hchar:='한';
     g_han_char(48).weight_val:=4;
     g_han_char(49).hchar:='함';
     g_han_char(49).weight_val:=1;
     g_han_char(50).hchar:='허';
     g_han_char(50).weight_val:=4;

     g_han_char_o(1).hchar:='가';
     g_han_char_o(2).hchar:='간';
     g_han_char_o(3).hchar:='감';
     g_han_char_o(4).hchar:='갑';
     g_han_char_o(5).hchar:='강';
     g_han_char_o(6).hchar:='개';
     g_han_char_o(7).hchar:='건';
     g_han_char_o(8).hchar:='검';
     g_han_char_o(9).hchar:='고';
     g_han_char_o(10).hchar:='곤';
     g_han_char_o(11).hchar:='곰';
     g_han_char_o(12).hchar:='곽';
     g_han_char_o(13).hchar:='관';
     g_han_char_o(14).hchar:='교';
     g_han_char_o(15).hchar:='구';
     g_han_char_o(16).hchar:='국';
     g_han_char_o(17).hchar:='군';
     g_han_char_o(18).hchar:='규';
     g_han_char_o(19).hchar:='균';
     g_han_char_o(20).hchar:='금';
     g_han_char_o(21).hchar:='기';
     g_han_char_o(22).hchar:='길';
     g_han_char_o(23).hchar:='김';
     g_han_char_o(24).hchar:='나';
     g_han_char_o(25).hchar:='낙';
     g_han_char_o(26).hchar:='난';
     g_han_char_o(27).hchar:='너';
     g_han_char_o(28).hchar:='녀';
     g_han_char_o(29).hchar:='노';
     g_han_char_o(30).hchar:='다';
     g_han_char_o(31).hchar:='단';
     g_han_char_o(32).hchar:='달';
     g_han_char_o(33).hchar:='담';
     g_han_char_o(34).hchar:='대';
     g_han_char_o(35).hchar:='도';
     g_han_char_o(36).hchar:='독';
     g_han_char_o(37).hchar:='돈';
     g_han_char_o(38).hchar:='동';
     g_han_char_o(39).hchar:='두';
     g_han_char_o(40).hchar:='둔';
     g_han_char_o(41).hchar:='둘';
     g_han_char_o(42).hchar:='래';
     g_han_char_o(43).hchar:='로';
     g_han_char_o(44).hchar:='리';
     g_han_char_o(45).hchar:='린';
     g_han_char_o(46).hchar:='림';
     g_han_char_o(47).hchar:='마';
     g_han_char_o(48).hchar:='막';
     g_han_char_o(49).hchar:='만';
     g_han_char_o(50).hchar:='망';
     g_han_char_o(51).hchar:='먹';
     g_han_char_o(52).hchar:='먼';
     g_han_char_o(53).hchar:='모';
     g_han_char_o(54).hchar:='목';
     g_han_char_o(55).hchar:='무';
     g_han_char_o(56).hchar:='묵';
     g_han_char_o(57).hchar:='문';
     g_han_char_o(58).hchar:='미';
     g_han_char_o(59).hchar:='민';
     g_han_char_o(60).hchar:='밀';
     g_han_char_o(61).hchar:='바';
     g_han_char_o(62).hchar:='박';
     g_han_char_o(63).hchar:='반';
     g_han_char_o(64).hchar:='발';
     g_han_char_o(65).hchar:='방';
     g_han_char_o(66).hchar:='배';
     g_han_char_o(67).hchar:='백';
     g_han_char_o(68).hchar:='번';
     g_han_char_o(69).hchar:='벌';
     g_han_char_o(70).hchar:='벽';
     g_han_char_o(71).hchar:='변';
     g_han_char_o(72).hchar:='병';
     g_han_char_o(73).hchar:='보';
     g_han_char_o(74).hchar:='복';
     g_han_char_o(75).hchar:='본';
     g_han_char_o(76).hchar:='봄';
     g_han_char_o(77).hchar:='봉';
     g_han_char_o(78).hchar:='부';
     g_han_char_o(79).hchar:='북';
     g_han_char_o(80).hchar:='분';
     g_han_char_o(81).hchar:='빈';
     g_han_char_o(82).hchar:='사';
     g_han_char_o(83).hchar:='삼';
     g_han_char_o(84).hchar:='새';
     g_han_char_o(85).hchar:='샘';
     g_han_char_o(86).hchar:='서';
     g_han_char_o(87).hchar:='석';
     g_han_char_o(88).hchar:='선';
     g_han_char_o(89).hchar:='성';
     g_han_char_o(90).hchar:='세';
     g_han_char_o(91).hchar:='소';
     g_han_char_o(92).hchar:='손';
     g_han_char_o(93).hchar:='송';
     g_han_char_o(94).hchar:='수';
     g_han_char_o(95).hchar:='숙';
     g_han_char_o(96).hchar:='순';
     g_han_char_o(97).hchar:='시';
     g_han_char_o(98).hchar:='식';
     g_han_char_o(99).hchar:='신';
     g_han_char_o(100).hchar:='실';
     g_han_char_o(101).hchar:='아';
     g_han_char_o(102).hchar:='악';
     g_han_char_o(103).hchar:='안';
     g_han_char_o(104).hchar:='야';
     g_han_char_o(105).hchar:='여';
     g_han_char_o(106).hchar:='역';
     g_han_char_o(107).hchar:='연';
     g_han_char_o(108).hchar:='열';
     g_han_char_o(109).hchar:='염';
     g_han_char_o(110).hchar:='영';
     g_han_char_o(111).hchar:='오';
     g_han_char_o(112).hchar:='옥';
     g_han_char_o(113).hchar:='온';
     g_han_char_o(114).hchar:='용';
     g_han_char_o(115).hchar:='우';
     g_han_char_o(116).hchar:='욱';
     g_han_char_o(117).hchar:='운';
     g_han_char_o(118).hchar:='웅';
     g_han_char_o(119).hchar:='위';
     g_han_char_o(120).hchar:='유';
     g_han_char_o(121).hchar:='육';
     g_han_char_o(122).hchar:='윤';
     g_han_char_o(123).hchar:='은';
     g_han_char_o(124).hchar:='을';
     g_han_char_o(125).hchar:='음';
     g_han_char_o(126).hchar:='의';
     g_han_char_o(127).hchar:='이';
     g_han_char_o(128).hchar:='익';
     g_han_char_o(129).hchar:='인';
     g_han_char_o(130).hchar:='일';
     g_han_char_o(131).hchar:='자';
     g_han_char_o(132).hchar:='작';
     g_han_char_o(133).hchar:='잔';
     g_han_char_o(134).hchar:='재';
     g_han_char_o(135).hchar:='적';
     g_han_char_o(136).hchar:='전';
     g_han_char_o(137).hchar:='정';
     g_han_char_o(138).hchar:='제';
     g_han_char_o(139).hchar:='조';
     g_han_char_o(140).hchar:='족';
     g_han_char_o(141).hchar:='존';
     g_han_char_o(142).hchar:='종';
     g_han_char_o(143).hchar:='주';
     g_han_char_o(144).hchar:='준';
     g_han_char_o(145).hchar:='중';
     g_han_char_o(146).hchar:='지';
     g_han_char_o(147).hchar:='직';
     g_han_char_o(148).hchar:='진';
     g_han_char_o(149).hchar:='찬';
     g_han_char_o(150).hchar:='창';
     g_han_char_o(151).hchar:='채';
     g_han_char_o(152).hchar:='철';
     g_han_char_o(153).hchar:='최';
     g_han_char_o(154).hchar:='추';
     g_han_char_o(155).hchar:='축';
     g_han_char_o(156).hchar:='춘';
     g_han_char_o(157).hchar:='출';
     g_han_char_o(158).hchar:='충';
     g_han_char_o(159).hchar:='판';
     g_han_char_o(160).hchar:='하';
     g_han_char_o(161).hchar:='학';
     g_han_char_o(162).hchar:='한';
     g_han_char_o(163).hchar:='함';
     g_han_char_o(164).hchar:='해';
     g_han_char_o(165).hchar:='허';
     g_han_char_o(166).hchar:='현';
     g_han_char_o(167).hchar:='헤';
     g_han_char_o(168).hchar:='혁';
     g_han_char_o(169).hchar:='현';
     g_han_char_o(170).hchar:='혜';
     g_han_char_o(171).hchar:='홍';
     g_han_char_o(172).hchar:='황';
     g_han_char_o(173).hchar:='.';
     g_han_char_o(174).hchar:=',';
     g_han_char_o(175).hchar:='? ';
     g_han_char_o(176).hchar:=' ';
     g_han_char_o(177).hchar:=' ';
     g_han_char_o(178).hchar:=' ';
     g_han_char_o(179).hchar:=' ';
     g_han_char_o(180).hchar:=' ';

--    FOR i IN 1..6 LOOP
--      g_han_char_o(i+g_han_char_o.count).hchar:=' ';
--    END LOOP;

    v_temp_counter:=0;
    FOR i IN 1..g_han_char.count LOOP
      FOR j IN 1..g_han_char(i).weight_val LOOP
        v_temp_counter:=v_temp_counter+1;
        g_han_char_w(v_temp_counter).hchar:=g_han_char(i).hchar;
      END LOOP;
    END LOOP;

    g_weighted_char_counter:=v_temp_counter;
    g_ordinary_char_counter:=g_han_char_o.count;
  EXCEPTION
     WHEN OTHERS
     THEN
        DBMS_OUTPUT.put_line ('Initialization Error');
  END initialize;

  PROCEDURE DROP_CONST(i_table_name in varchar2 default 'ALL')
  IS
    v_table_name varchar2(30);
  BEGIN
    v_table_name:=upper(trim(i_table_name));

    if v_table_name is null or v_table_name='ALL' then
      begin
        execute immediate 'ALTER TABLE "CUST_CONTACTS" DROP CONSTRAINT "CUST_CONTACTS_R1"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "DEPARTMENTS" DROP CONSTRAINT "DEPARTMENTS_R1"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "EMPLOYEES" DROP CONSTRAINT "EMPLOYEES_R1"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "EMPLOYEES" DROP CONSTRAINT "EMPLOYEES_R2"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "INQUIRIES" DROP CONSTRAINT "INQUIRIES_R1"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "INQUIRIES" DROP CONSTRAINT "INQUIRIES_R2"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "INQUIRIES" DROP CONSTRAINT "INQUIRIES_R3"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "INQUIRIES" DROP CONSTRAINT "INQUIRIES_R4"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "ORDERS" DROP CONSTRAINT "ORDERS_R1"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "ORDERS" DROP CONSTRAINT "ORDERS_R2"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "ORDER_ITEMS" DROP CONSTRAINT "ORDER_ITEMS_R1"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "ORDER_ITEMS" DROP CONSTRAINT "ORDER_ITEMS_R2"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "PRODUCTS" DROP CONSTRAINT "PRODUCTS_R1"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "PRODUCTS" DROP CONSTRAINT "PRODUCTS_R2"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "SHIPMENTS" DROP CONSTRAINT "SHIPMENTS_R1"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "SHIPMENTS" DROP CONSTRAINT "SHIPMENTS_R2"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "SHIPMENTS" DROP CONSTRAINT "SHIPMENTS_R3"';
      exception
        when others then
          NULL;
      end;

      begin
        execute immediate 'ALTER TABLE "SHIPMENT_ADDRESSES" DROP CONSTRAINT "SHIPMENT_ADDRESS_R1"';
      exception
        when others then
          NULL;
      end;
    else
      for str in (select constraint_name from all_constraints where table_name='SHIPMENTS' and CONSTRAINT_TYPE='R' and table_name=v_table_name order by constraint_name) loop
        execute immediate 'alter table ' || v_table_name || ' drop constraint ' || str.constraint_name;
      end loop;
    end if;

  END DROP_CONST;

  PROCEDURE CRE_CONST
  IS
  BEGIN
    begin
      execute immediate 'ALTER TABLE "CUST_CONTACTS" ADD CONSTRAINT "CUST_CONTACTS_R1" FOREIGN KEY ("CUST_ID") REFERENCES "CUSTOMERS" ("CUST_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "DEPARTMENTS" ADD CONSTRAINT "DEPARTMENTS_R1" FOREIGN KEY ("UPPER_DEPT_ID") REFERENCES "DEPARTMENTS" ("DEPT_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "EMPLOYEES" ADD CONSTRAINT "EMPLOYEES_R1" FOREIGN KEY ("DEPT_ID") REFERENCES "DEPARTMENTS" ("DEPT_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "EMPLOYEES" ADD CONSTRAINT "EMPLOYEES_R2" FOREIGN KEY ("ADMIN_EMP_ID") REFERENCES "EMPLOYEES" ("EMP_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "INQUIRIES" ADD CONSTRAINT "INQUIRIES_R1" FOREIGN KEY ("CUST_ID") REFERENCES "CUSTOMERS" ("CUST_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "INQUIRIES" ADD CONSTRAINT "INQUIRIES_R2" FOREIGN KEY ("ORDER_ID") REFERENCES "ORDERS" ("ORDER_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "INQUIRIES" ADD CONSTRAINT "INQUIRIES_R4" FOREIGN KEY ("EMP_ID") REFERENCES "EMPLOYEES" ("EMP_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "INQUIRIES" ADD CONSTRAINT "INQUIRIES_R3" FOREIGN KEY ("PRODUCT_ID") REFERENCES "PRODUCTS" ("PRODUCT_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "ORDERS" ADD CONSTRAINT "ORDERS_R1" FOREIGN KEY ("CUST_ID") REFERENCES "CUSTOMERS" ("CUST_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "ORDERS" ADD CONSTRAINT "ORDERS_R2" FOREIGN KEY ("ORDER_RCT_EMP_ID") REFERENCES "EMPLOYEES" ("EMP_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "ORDER_ITEMS" ADD CONSTRAINT "ORDER_ITEMS_R1" FOREIGN KEY ("ORDER_ID") REFERENCES "ORDERS" ("ORDER_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "ORDER_ITEMS" ADD CONSTRAINT "ORDER_ITEMS_R2" FOREIGN KEY ("PRODUCT_ID") REFERENCES "PRODUCTS" ("PRODUCT_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "PRODUCTS" ADD CONSTRAINT "PRODUCTS_R1" FOREIGN KEY ("CATEGORY_ID") REFERENCES "CATEGORIES" ("CATEGORY_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "PRODUCTS" ADD CONSTRAINT "PRODUCTS_R2" FOREIGN KEY ("VENDOR_ID") REFERENCES "CORPORATIONS" ("CORPORATION_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "SHIPMENTS" ADD CONSTRAINT "SHIPMENTS_R1" FOREIGN KEY ("CUST_ID") REFERENCES "CUSTOMERS" ("CUST_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "SHIPMENTS" ADD CONSTRAINT "SHIPMENTS_R2" FOREIGN KEY ("ORDER_ID") REFERENCES "ORDERS" ("ORDER_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "SHIPMENTS" ADD CONSTRAINT "SHIPMENTS_R3" FOREIGN KEY ("SHIPMENT_CORPORATION_ID") REFERENCES "CORPORATIONS" ("CORPORATION_ID")';
    exception
      when others then
        NULL;
    end;
    begin
      execute immediate 'ALTER TABLE "SHIPMENT_ADDRESSES" ADD CONSTRAINT "SHIPMENT_ADDRESS_R1" FOREIGN KEY ("CUST_ID") REFERENCES "CUSTOMERS" ("CUST_ID")';
    exception
      when others then
        NULL;
    end;
  END CRE_CONST;

  PROCEDURE DEL_TABLES
  IS
  BEGIN
    DROP_CONST('ALL');

    execute immediate 'TRUNCATE TABLE SHIPMENTS';
    execute immediate 'TRUNCATE TABLE DEPARTMENTS';
    execute immediate 'TRUNCATE TABLE EMPLOYEES';
    execute immediate 'TRUNCATE TABLE ORDERS';
    execute immediate 'TRUNCATE TABLE CUST_CONTACTS';
    execute immediate 'TRUNCATE TABLE SHIPMENT_ADDRESSES';
    execute immediate 'TRUNCATE TABLE INQUIRIES';
    execute immediate 'TRUNCATE TABLE PRODUCTS';
    execute immediate 'TRUNCATE TABLE SHIPMENTS';
    execute immediate 'TRUNCATE TABLE ORDER_ITEMS';
    execute immediate 'TRUNCATE TABLE ORDERS';
    execute immediate 'TRUNCATE TABLE CORPORATIONS';
    execute immediate 'TRUNCATE TABLE CATEGORIES';
  END DEL_TABLES;

  PROCEDURE CRE_CATEGORIES
  IS
  BEGIN
    delete categories;
    insert into categories(category_id,category_name) values(1,'도서');
    insert into categories(category_id,category_name) values(2,'음반');
    insert into categories(category_id,category_name) values(3,'영상물');
    insert into categories(category_id,category_name) values(4,'기타상품');
    commit;
  END CRE_CATEGORIES;

  PROCEDURE CRE_DEPARTMENTS
  IS
  BEGIN
    delete departments;
    INSERT INTO departments(dept_id,dept_name,upper_dept_id) values(500,'출하부문',NULL);
    INSERT INTO departments(dept_id,dept_name,upper_dept_id) values(700,'고객만족사업부',500);
    INSERT INTO departments(dept_id,dept_name,upper_dept_id) values(710,'고객만족1팀',700);
    INSERT INTO departments(dept_id,dept_name,upper_dept_id) values(720,'고객만족2팀',700);
    INSERT INTO departments(dept_id,dept_name,upper_dept_id) values(730,'고객만족3팀',700);
    INSERT INTO departments(dept_id,dept_name,upper_dept_id) values(600,'주문출하사업부',500);
    INSERT INTO departments(dept_id,dept_name,upper_dept_id) values(610,'주문접수팀',600);
    INSERT INTO departments(dept_id,dept_name,upper_dept_id) values(620,'상품출하팀',600);
    COMMIT;
  END CRE_DEPARTMENTS;

  PROCEDURE CRE_CORPORATIONS(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_adjV      number;   --생성 대상건수
    v_cnt       number;   --생성 건수
    v_cursor    int;
    v_status    int;
    v_co_type   int;
    c_cp_id     dbms_sql.number_table;  --협력업체 ID
    c_cp_name   dbms_sql.varchar2_table;  --협력업체 이름
    c_cp_number dbms_sql.varchar2_table;  --협력업체 대표 연락처
    c_cp_type   dbms_sql.varchar2_table;  --협력업체 구분
    v_cp_name   varchar2(40);  --임시 협력업체 이름
    v_cp_number varchar2(40);  --임시 협력업체 대표 연락처
    v_name_cnt  number;  --임시 협력업체 이름 길이

    c_empty_tab_num     dbms_sql.number_table;    --Empty Table 숫자
    c_empty_tab_chr     dbms_sql.varchar2_table;  --Empty Table 문자

    l_loop_cnt1 number;
    l_loop_cnt2 number;
    l_loop_cnt3 number;

  BEGIN
    delete CORPORATIONS;

    dbms_random.seed(i_seed_val);

    v_co_type:=3;
    v_cnt:=0;

    FOR l_loop_cnt1 IN 1..v_co_type LOOP
      v_adjV:=trunc(least(trunc(i_volume/50),trunc(ln(i_volume)*10))*1.1/l_loop_cnt1);

      c_cp_id:=c_empty_tab_num;
      c_cp_name:=c_empty_tab_chr;
      c_cp_number:=c_empty_tab_chr;
      c_cp_type:=c_empty_tab_chr;
      FOR l_loop_cnt2 IN 1..v_adjV LOOP
        v_cnt:=v_cnt+1;
        v_name_cnt:=trunc(dbms_random.value(2,10));
        v_cp_name:='';
        v_cp_number:='';
        c_cp_id(l_loop_cnt2):=v_cnt;
        FOR l_loop_cnt3 in 1..v_name_cnt LOOP
          v_cp_name:=v_cp_name||g_han_char_o(ceil(dbms_random.value*g_ordinary_char_counter)).hchar;
        END LOOP;
        c_cp_name(l_loop_cnt2):='(주)'||v_cp_name;
        FOR l_loop_cnt3 in 1..10 LOOP
          v_cp_number:=v_cp_number||trunc(dbms_random.value*10);
        END LOOP;
        c_cp_number(l_loop_cnt2):=v_cp_number;
        c_cp_type(l_loop_cnt2):=l_loop_cnt1;
      END LOOP;
      v_cursor := dbms_sql.open_cursor;
      dbms_sql.parse( v_cursor,
                     'insert into CORPORATIONS(CORPORATION_id,CORPORATION_name,rep_phone_number,CORPORATION_type) values(:b0,:b1,:b2,:b3)',
                      dbms_sql.native );
      dbms_sql.bind_array(v_cursor, ':b0', c_cp_id );
      dbms_sql.bind_array(v_cursor, ':b1', c_cp_name );
      dbms_sql.bind_array(v_cursor, ':b2', c_cp_number );
      dbms_sql.bind_array(v_cursor, ':b3', c_cp_type );
      v_status := dbms_sql.execute( v_cursor );
      dbms_sql.close_cursor(v_cursor);
    END LOOP;
    COMMIT;
  END CRE_CORPORATIONS;

  PROCEDURE CRE_PRODUCTS(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_adjV      number;   --생성 대상건수
    v_cnt       number;   --생성 건수
    v_cursor    int;
    v_status    int;

    v_co_type   int;      --협력업체 Type 수
    c_product_id      dbms_sql.number_table;    --상품ID
    c_category_id     dbms_sql.number_table;    --카테고리ID
    c_vendor_id       dbms_sql.number_table;    --공급자ID
    c_product_name    dbms_sql.varchar2_table;  --상품이름
    c_isbn_no         dbms_sql.varchar2_table;  --국제표준도서번호
    c_product_price   dbms_sql.number_table;    --표준가격
    c_writer_name     dbms_sql.varchar2_table;  --저자이름

    v_product_name    varchar2(60);  --상품이름
    v_product_name_cnt  number;  --상품이름길이 범위
    v_writer_name     varchar2(40);  --저자이름
    v_isbn_no         varchar2(40);  --국제표준도서번호

    v_publisher_id_min  number;      --출판사ID 최소
    v_publisher_id_max  number;      --출판사ID 최대
    v_vendor_id_min  number;         --공급사ID 최소
    v_vendor_id_max  number;         --공급사ID 최대
    v_vendor_id       number;        --공급사ID 임시
    v_category_id_min  number;       --카테고리ID 최소
    v_category_id_max  number;       --카테고리ID 최대

    c_empty_tab_num     dbms_sql.number_table;    --Empty Table 숫자
    c_empty_tab_chr     dbms_sql.varchar2_table;  --Empty Table 문자

    l_loop_cnt1 number;
    l_loop_cnt2 number;
    l_loop_cnt3 number;

  BEGIN
    DROP_CONST('PRODUCTS');
    execute immediate 'TRUNCATE TABLE PRODUCTS';

    dbms_random.seed(i_seed_val);

    v_co_type:=2;
    v_cnt:=0;

    select min(CORPORATION_id),max(CORPORATION_id) into v_publisher_id_min,v_publisher_id_max from CORPORATIONS where CORPORATION_type='1';
    select min(CORPORATION_id),max(CORPORATION_id) into v_vendor_id_min,v_vendor_id_max from CORPORATIONS where CORPORATION_type='2';
    select min(category_id),max(category_id) into v_category_id_min,v_category_id_max from categories;

    FOR l_loop_cnt1 IN 1..2 LOOP          --출판사,공급사만 수행
      v_adjV:=i_volume*3*2/l_loop_cnt1;

      c_product_id:=c_empty_tab_num;
      c_category_id:=c_empty_tab_num;
      c_vendor_id:=c_empty_tab_num;
      c_product_name:=c_empty_tab_chr;
      c_isbn_no:=c_empty_tab_chr;
      c_product_price:=c_empty_tab_num;
      c_writer_name:=c_empty_tab_chr;

      FOR l_loop_cnt2 IN 1..v_adjV LOOP
        v_cnt:=v_cnt+1;
        v_product_name_cnt:=trunc(dbms_random.value(3,14));
        c_product_id(l_loop_cnt2):=v_cnt;
        c_category_id(l_loop_cnt2):=least(greatest(trunc(dbms_random.value*ln(dbms_random.value+l_loop_cnt1*0.5)*(v_category_id_max-v_category_id_min+1))+l_loop_cnt1,v_category_id_min),v_category_id_max);
        IF l_loop_cnt1=1 THEN
          v_vendor_id:=least(greatest(trunc(dbms_random.value*ln(dbms_random.value+l_loop_cnt1*0.8)*(v_publisher_id_max-v_publisher_id_min+1)+dbms_random.value(v_publisher_id_min,v_publisher_id_max))+1,v_publisher_id_min),v_publisher_id_max);
          IF mod(v_vendor_id,trunc(29*l_loop_cnt2/2))=0 then
            v_vendor_id:=least(greatest(v_vendor_id-trunc(l_loop_cnt2/2),v_publisher_id_min),v_publisher_id_max);
          END IF;
          c_vendor_id(l_loop_cnt2):=v_vendor_id;
        ELSE
          v_vendor_id:=least(greatest(trunc(dbms_random.value*ln(dbms_random.value+l_loop_cnt1*0.8)*(v_vendor_id_max-v_vendor_id_min+1)+dbms_random.value(v_vendor_id_min,v_vendor_id_max))+1,v_vendor_id_min),v_vendor_id_max);
          IF mod(v_vendor_id,trunc(31*l_loop_cnt2/2))=0 then
            v_vendor_id:=least(greatest(trunc(v_vendor_id-(l_loop_cnt2/2)),v_vendor_id_min),v_vendor_id_max);
          END IF;
          c_vendor_id(l_loop_cnt2):=v_vendor_id;
        END IF;
--        v_product_name:='';
--        FOR l_loop_cnt3 in 1..v_product_name_cnt LOOP
--          v_product_name:=v_product_name||g_han_char_o(ceil(dbms_random.value*g_ordinary_char_counter)).hchar;
--        END LOOP;
        v_product_name:=cre_han_string(3,15,'1');
        c_product_name(l_loop_cnt2):=rtrim(v_product_name);
        IF c_category_id(l_loop_cnt2)=1 THEN
          v_isbn_no:='97889';
          FOR l_loop_cnt3 in 1..12 LOOP
            v_isbn_no:=v_isbn_no||trunc(dbms_random.value*10);
          END LOOP;
          v_isbn_no:=v_isbn_no||'0';
          c_isbn_no(l_loop_cnt2):=v_isbn_no;
          c_writer_name(l_loop_cnt2):=cre_han_string(2,4,'2');
        ELSE
          c_isbn_no(l_loop_cnt2):=NULL;
          c_writer_name(l_loop_cnt2):=NULL;
        END IF;
        c_product_price(l_loop_cnt2):=trunc(greatest((dbms_random.value*20000+20000)*ln(dbms_random.value*10)+3000,3000*dbms_random.value(1,3)),-2);

      END LOOP;
      v_cursor := dbms_sql.open_cursor;
      dbms_sql.parse( v_cursor,
                     'insert into products(product_id,category_id,vendor_id,product_name,isbn_no,product_price,writer_name) values(:b0,:b1,:b2,:b3,:b4,:b5,:b6)',
                      dbms_sql.native );
      dbms_sql.bind_array(v_cursor, ':b0', c_product_id );
      dbms_sql.bind_array(v_cursor, ':b1', c_category_id );
      dbms_sql.bind_array(v_cursor, ':b2', c_vendor_id );
      dbms_sql.bind_array(v_cursor, ':b3', c_product_name );
      dbms_sql.bind_array(v_cursor, ':b4', c_isbn_no );
      dbms_sql.bind_array(v_cursor, ':b5', c_product_price );
      dbms_sql.bind_array(v_cursor, ':b6', c_writer_name );
      v_status := dbms_sql.execute( v_cursor );
      dbms_sql.close_cursor(v_cursor);
    END LOOP;
    COMMIT;
  END CRE_PRODUCTS;

  PROCEDURE CRE_CUSTOMERS(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_adjV      number;   --생성 대상건수
    v_cnt       number;   --생성 건수
    v_cursor    int;
    v_status    int;

    c_cust_id           dbms_sql.number_table;    --고객ID
    c_cust_name         dbms_sql.varchar2_table;  --고객이름
    c_cust_gender_type  dbms_sql.varchar2_table;  --성별구분
    c_login_id          dbms_sql.varchar2_table;  --로그인ID
    c_login_pswd        dbms_sql.varchar2_table;  --로그인비밀번호
    c_login_name        dbms_sql.varchar2_table;  --접속별명

    v_cust_name         varchar2(40);   --고객이름
    v_cust_gender_type  varchar2(1);    --고객성별
    v_login_id          varchar2(10);   --로그인ID
    v_login_pawd        varchar2(64);   --로그인비밀번호
    v_login_name        varchar2(40);   --접속별명
    v_cust_name_cnt     number;         --고객이름글자수

    c_empty_tab_num     dbms_sql.number_table;    --Empty Table 숫자
    c_empty_tab_chr     dbms_sql.varchar2_table;  --Empty Table 문자

    l_loop_cnt1 number;
    l_loop_cnt2 number;
    l_loop_cnt3 number;

  BEGIN
    DROP_CONST('CUSTOMERS');
    execute immediate 'TRUNCATE TABLE CUSTOMERS';

    dbms_random.seed(i_seed_val);

    v_cnt:=0;
    v_adjV:=i_volume;                   --고객 수는 입력받은 수만큼 생성

    FOR l_loop_cnt1 IN 1..v_adjV LOOP
      v_cnt:=v_cnt+1;
      v_cust_name:=cre_han_string(2,4,'2');
--      v_cust_name_cnt:=3-round(log(dbms_random.value(2,17),2)*2,0);
--      v_cust_name:=g_han_char_w(ceil(dbms_random.value*g_weighted_char_counter)).hchar;
--      FOR l_loop_cnt2 in 1..v_cust_name_cnt LOOP
--        v_cust_name:=v_cust_name||g_han_char_o(ceil(dbms_random.value*g_ordinary_char_counter)).hchar;
--      END LOOP;
      v_cust_gender_type:=round(dbms_random.value(1,2),0);
      v_login_id:=dbms_random.string('X',trunc(dbms_random.value(3,10)));
      v_login_pawd:=dbms_utility.get_hash_value(v_login_id,1000000000,1000000000);
      IF dbms_random.value>0.4 THEN
        v_login_name:='';
        v_cust_name_cnt:=round(dbms_random.value(3,8),0);
        FOR l_loop_cnt2 in 1..v_cust_name_cnt LOOP
          v_login_name:=v_login_name||g_han_char_o(ceil(dbms_random.value*g_ordinary_char_counter)).hchar;
        END LOOP;
      ELSE
        v_login_name:=v_cust_name;
      END IF;

      c_cust_id(l_loop_cnt1):=v_cnt;
      c_cust_name(l_loop_cnt1):=v_cust_name;
      c_cust_gender_type(l_loop_cnt1):=v_cust_gender_type;
      c_login_id(l_loop_cnt1):=v_login_id;
      c_login_pswd(l_loop_cnt1):=v_login_pawd;
      c_login_name(l_loop_cnt1):=v_login_name;
    END LOOP;
    v_cursor := dbms_sql.open_cursor;
    dbms_sql.parse( v_cursor,
                   'insert into customers(cust_id,cust_name,cust_gender_type,login_id,login_pswd,login_name,cust_grade) values(:b0,:b1,:b2,:b3,:b4,:b5,''0'')',
                    dbms_sql.native );
    dbms_sql.bind_array(v_cursor, ':b0', c_cust_id );
    dbms_sql.bind_array(v_cursor, ':b1', c_cust_name );
    dbms_sql.bind_array(v_cursor, ':b2', c_cust_gender_type );
    dbms_sql.bind_array(v_cursor, ':b3', c_login_id );
    dbms_sql.bind_array(v_cursor, ':b4', c_login_pswd );
    dbms_sql.bind_array(v_cursor, ':b5', c_login_name );
    v_status := dbms_sql.execute( v_cursor );
    dbms_sql.close_cursor(v_cursor);

    COMMIT;
  END CRE_CUSTOMERS;

  PROCEDURE CRE_EMPLOYEES(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_adjV      number;   --생성 대상건수
  BEGIN
    DROP_CONST('EMPLOYEES');
    execute immediate 'TRUNCATE TABLE EMPLOYEES';

    dbms_random.seed(i_seed_val);

    v_adjV:=i_volume;

    insert into employees
    (
      emp_id
      ,emp_name
      ,dept_id
      ,admin_emp_id
      ,hire_date
      ,job_position
      ,salary
    )
    select 1,'김사장',NULL,NULL,to_date('20010103','YYYYMMDD'),1,9500000 from dual
    union all
    select 6,'박전무',600,1,to_date('20050303','YYYYMMDD'),3,5500000 from dual
    union all
    select 7,'송전무',700,1,to_date('20030303','YYYYMMDD'),3,5450000 from dual
    union all
    select
      emp_id
      ,cre_han_string(2,4,'2')
      ,dept_id emp_name
      ,decode(rnk,1,trunc(dept_id/100),admin_emp_id) admin_emp_id
      ,hdate
      ,position
      ,salary
    from
      (
      select
        emp_id
        ,dept_id
        ,hdate
        ,position
        ,trunc((10-position)*ln(((10-position)*dbms_random.value(50,300)))*100000+1000000,-4) salary
        ,rank() over(partition by dept_id order by position,hdate) rnk
        ,first_value(emp_id) over(partition by dept_id order by position,hdate) admin_emp_id
      from
        (
        select
          ceil(rownum+8*1.08) emp_id
          ,hdate
          ,dept_id
          ,greatest(least(round((hdate-to_date('20010101','yyyymmdd'))*ln(dbms_random.value(3,8))/500,0)+4,9),3) position
        from
          (
          select
            trunc(to_date('20010101','yyyymmdd')+dbms_random.value*5000,'mm') hdate
            ,v.dept_id
          from
--            (select rownum rnum,trunc(mod(rownum+dbms_random.value(1,10),6))+1 rdept from dual connect by rownum<=v_adjV/(ln(v_adjV)*ln(v_adjV)*10)) a
            (select rownum rnum,trunc(mod(rownum+dbms_random.value(1,10),4))+round(dbms_random.value(0.9,2.6),0) rdept from dual connect by rownum<=v_adjV/(ln(v_adjV)*ln(v_adjV)*10)) a
            ,(
            select rownum rnum,dept_id
            from departments
            where dept_name not in ('고객만족사업부','고객만족3팀','주문출하사업부','출하부문')
            ) v
          where
            a.rdept=v.rnum
          order by hdate
          )
        )
      );
    commit;
  END CRE_EMPLOYEES;

  PROCEDURE CRE_SHIPMENT_ADDRESSES(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    TYPE rec_weight_val IS RECORD (
      weight_val NUMBER(2)
    );
    TYPE tab_weight_val IS TABLE OF rec_weight_val INDEX BY pls_integer;
    v_tab_weight_val tab_weight_val;

    v_m_var     number;   --생성 배수
    v_adjV      number;   --생성 대상건수
    v_temp_var  number;
    l_loop_cnt1 number;

  BEGIN
    DROP_CONST('SHIPMENT_ADDRESSES');
    execute immediate 'TRUNCATE TABLE SHIPMENT_ADDRESSES';

    dbms_random.seed(i_seed_val);

    v_m_var:=1.2;
    v_adjV:=i_volume*v_m_var;

    v_tab_weight_val(1).weight_val:=0.83;
    v_tab_weight_val(2).weight_val:=0.14;
    v_tab_weight_val(3).weight_val:=0.03;

      insert into shipment_addresses
      (
        cust_id
        ,ship_addr_ord_num
        ,ship_addr_base_yn
        ,ship_addr_reg_dt
        ,region_type
        ,zipcode
        ,address
      )
      with
        cv_a as
          (
          select
            idx
            ,region_name
            ,w_val
            ,cum_sum
            ,nvl(p_cum_sum,1) start_cum_sum
            ,total_num
          from
            (
            select
              idx
              ,region_name
              ,w_val
              ,cum_sum
              ,lag(cum_sum) over(order by idx) p_cum_sum
              ,max(cum_sum) over() total_num
            from
              (
              select
                idx
                ,region_name
                ,w_val
                ,sum(w_val) over(order by idx) cum_sum
              from
                (
                select 1 idx,'서울특별시' region_name,49 w_val from dual union all
                select 2 idx,'부산광역시' region_name,17 w_val from dual union all
                select 3 idx,'대구광역시' region_name,12 w_val from dual union all
                select 4 idx,'인천광역시' region_name,14 w_val from dual union all
                select 5 idx,'광주광역시' region_name,7  w_val from dual union all
                select 6 idx,'대전광역시' region_name,8  w_val from dual union all
                select 7 idx,'울산광역시' region_name,6  w_val from dual union all
                select 8 idx,'세종특별시' region_name,1  w_val from dual union all
                select 9 idx,'경기도' region_name,61 w_val from dual union all
                select 10 idx,'강원도' region_name,7 w_val from dual union all
                select 11 idx,'충청북도' region_name,8  w_val from dual union all
                select 12 idx,'충청남도' region_name,10 w_val from dual union all
                select 13 idx,'전라북도' region_name,9  w_val from dual union all
                select 14 idx,'전라남도' region_name,9  w_val from dual union all
                select 15 idx,'경상북도' region_name,13 w_val from dual union all
                select 16 idx,'경상남도' region_name,16 w_val from dual union all
                select 17 idx,'제주특별자치도' region_name,3 w_val from dual
                )
              )
            )
          )
        ,cv_b as
          (
          select max(total_num) total_num from cv_a
          )
      select /*+ NO_MERGE(C) */
        c.cust_id
        ,1
        ,'N'
        ,to_date('20010110','YYYYMMDD')+dbms_random.value*5000
        ,cv_a.idx
        ,to_char(20-cv_a.idx)||trim(to_char(trunc(dbms_random.value(1,999)),'009'))
        ,rpad(cv_a.region_name,dbms_random.value(30,70),'#') address
      from
        (
        select /*+ LEADING(V) NO_MERGE(V) */ distinct 
          c.cust_id
          ,trunc(dbms_random.value(1,(select total_num from cv_b))) ridx
        from customers c
          , (select trunc(rownum*(1/(v_m_var*0.83))) cust_id from customers where rownum<=v_adjV*0.83) v
        where
          c.cust_id=v.cust_id
        ) c
        ,cv_a
      where c.ridx>=cv_a.start_cum_sum
        and c.ridx<cv_a.cum_sum;

      insert into shipment_addresses
      (
        cust_id
        ,ship_addr_ord_num
        ,ship_addr_base_yn
        ,ship_addr_reg_dt
        ,region_type
        ,zipcode
        ,address
      )
      with
        cv_a as
          (
          select
            idx
            ,region_name
            ,w_val
            ,cum_sum
            ,nvl(p_cum_sum,1) start_cum_sum
            ,total_num
          from
            (
            select
              idx
              ,region_name
              ,w_val
              ,cum_sum
              ,lag(cum_sum) over(order by idx) p_cum_sum
              ,max(cum_sum) over() total_num
            from
              (
              select
                idx
                ,region_name
                ,w_val
                ,sum(w_val) over(order by idx) cum_sum
              from
                (
                select 1 idx,'서울특별시' region_name,49 w_val from dual union all
                select 2 idx,'부산광역시' region_name,17 w_val from dual union all
                select 3 idx,'대구광역시' region_name,12 w_val from dual union all
                select 4 idx,'인천광역시' region_name,14 w_val from dual union all
                select 5 idx,'광주광역시' region_name,7  w_val from dual union all
                select 6 idx,'대전광역시' region_name,8  w_val from dual union all
                select 7 idx,'울산광역시' region_name,6  w_val from dual union all
                select 8 idx,'세종특별시' region_name,1  w_val from dual union all
                select 9 idx,'경기도' region_name,61 w_val from dual union all
                select 10 idx,'강원도' region_name,7 w_val from dual union all
                select 11 idx,'충청북도' region_name,8  w_val from dual union all
                select 12 idx,'충청남도' region_name,10 w_val from dual union all
                select 13 idx,'전라북도' region_name,9  w_val from dual union all
                select 14 idx,'전라남도' region_name,9  w_val from dual union all
                select 15 idx,'경상북도' region_name,13 w_val from dual union all
                select 16 idx,'경상남도' region_name,16 w_val from dual union all
                select 17 idx,'제주특별자치도' region_name,3 w_val from dual
                )
              )
            )
          )
        ,cv_b as
          (
          select max(total_num) total_num from cv_a
          )
      select /*+ NO_MERGE(C) */
        c.cust_id
        ,2
        ,'N'
        ,to_date('20020101','YYYYMMDD')+dbms_random.value*4700
        ,cv_a.idx
        ,to_char(20-cv_a.idx)||trim(to_char(trunc(dbms_random.value(1,999)),'009'))
        ,rpad(cv_a.region_name,dbms_random.value(30,70),'#') address
      from
        (
        select /*+ LEADING(V) NO_MERGE(V) */ distinct 
          c.cust_id
          ,trunc(dbms_random.value(1,(select total_num from cv_b))) ridx
        from customers c
          , (select trunc(rownum*(1/(v_m_var*0.14))) cust_id from customers where rownum<=v_adjV*0.14) v
        where
          c.cust_id=v.cust_id
        ) c
        ,cv_a
      where c.ridx>=cv_a.start_cum_sum
        and c.ridx<cv_a.cum_sum;

      insert into shipment_addresses
      (
        cust_id
        ,ship_addr_ord_num
        ,ship_addr_base_yn
        ,ship_addr_reg_dt
        ,region_type
        ,zipcode
        ,address
      )
      with
        cv_a as
          (
          select
            idx
            ,region_name
            ,w_val
            ,cum_sum
            ,nvl(p_cum_sum,1) start_cum_sum
            ,total_num
          from
            (
            select
              idx
              ,region_name
              ,w_val
              ,cum_sum
              ,lag(cum_sum) over(order by idx) p_cum_sum
              ,max(cum_sum) over() total_num
            from
              (
              select
                idx
                ,region_name
                ,w_val
                ,sum(w_val) over(order by idx) cum_sum
              from
                (
                select 1 idx,'서울특별시' region_name,49 w_val from dual union all
                select 2 idx,'부산광역시' region_name,17 w_val from dual union all
                select 3 idx,'대구광역시' region_name,12 w_val from dual union all
                select 4 idx,'인천광역시' region_name,14 w_val from dual union all
                select 5 idx,'광주광역시' region_name,7  w_val from dual union all
                select 6 idx,'대전광역시' region_name,8  w_val from dual union all
                select 7 idx,'울산광역시' region_name,6  w_val from dual union all
                select 8 idx,'세종특별시' region_name,1  w_val from dual union all
                select 9 idx,'경기도' region_name,61 w_val from dual union all
                select 10 idx,'강원도' region_name,7 w_val from dual union all
                select 11 idx,'충청북도' region_name,8  w_val from dual union all
                select 12 idx,'충청남도' region_name,10 w_val from dual union all
                select 13 idx,'전라북도' region_name,9  w_val from dual union all
                select 14 idx,'전라남도' region_name,9  w_val from dual union all
                select 15 idx,'경상북도' region_name,13 w_val from dual union all
                select 16 idx,'경상남도' region_name,16 w_val from dual union all
                select 17 idx,'제주특별자치도' region_name,3 w_val from dual
                )
              )
            )
          )
        ,cv_b as
          (
          select max(total_num) total_num from cv_a
          )
      select /*+ NO_MERGE(C) */
        c.cust_id
        ,3
        ,'N'
        ,to_date('20030101','YYYYMMDD')+dbms_random.value*4300
        ,cv_a.idx
        ,to_char(20-cv_a.idx)||trim(to_char(trunc(dbms_random.value(1,999)),'009'))
        ,rpad(cv_a.region_name,dbms_random.value(30,70),'#') address
      from
        (
        select /*+ LEADING(V) NO_MERGE(V) */ distinct 
          c.cust_id
          ,trunc(dbms_random.value(1,(select total_num from cv_b))) ridx
        from customers c
          , (select trunc(rownum*(1/(v_m_var*0.03))) cust_id from customers where rownum<=v_adjV*0.03) v
        where
          c.cust_id=v.cust_id
        ) c
        ,cv_a
      where c.ridx>=cv_a.start_cum_sum
        and c.ridx<cv_a.cum_sum;
      commit;

      merge into shipment_addresses a
      using
      (
        select cust_id,max(ship_addr_reg_dt) ship_addr_reg_dt
        from shipment_addresses
        group by cust_id
      ) b
      on (a.cust_id=b.cust_id and a.ship_addr_reg_dt=b.ship_addr_reg_dt)
      when matched then
        update set a.ship_addr_base_yn='Y';
    commit;
  END CRE_SHIPMENT_ADDRESSES;

  PROCEDURE CRE_CUST_CONTACTS(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_m_var1    number;   --전화 생성 배수
    v_m_var2    number;   --EMail 생성 배수

    v_adjV1      number;   --전화 생성 대상건수
    v_adjV2      number;   --EMail 생성 대상건수
    v_temp_var  number;
    l_loop_cnt1 number;

  BEGIN
    DROP_CONST('CUST_CONTACTS');
    execute immediate 'TRUNCATE TABLE CUST_CONTACTS';

    dbms_random.seed(i_seed_val);

    v_m_var1:=1.4;
    v_m_var2:=0.8;
    v_adjV1:=i_volume*v_m_var1;
    v_adjV2:=i_volume*v_m_var2;

    insert into cust_contacts
    (
      cust_id
      ,contact_type
      ,contact_ord_num
      ,contact_value
      ,contact_base_yn
      ,contact_reg_dt
    )
    select
      cust_id
      ,1
      ,1
      ,'010' || trim(to_char(trunc(dbms_random.value(10000000,99999999)),'00000009'))
      ,'N'
      ,to_date('20010110','YYYYMMDD')+dbms_random.value*5000
    from
      (
      select
        c.cust_id
      from customers c
        ,(select trunc(rownum*(1/(v_m_var1*0.714))) cust_id from customers where rownum<=v_adjV1*0.714) v
      where
        c.cust_id=v.cust_id
      );

    insert into cust_contacts
    (
      cust_id
      ,contact_type
      ,contact_ord_num
      ,contact_value
      ,contact_base_yn
      ,contact_reg_dt
    )
    select
      cust_id
      ,1
      ,2
      ,'010' || trim(to_char(trunc(dbms_random.value(10000000,99999999)),'00000009'))
      ,'N'
      ,to_date('20020101','YYYYMMDD')+dbms_random.value*4700
    from
      (
      select
        c.cust_id
      from customers c
        ,(select trunc(rownum*(1/(v_m_var1*0.286))) cust_id from customers where rownum<=v_adjV1*0.286) v
      where
        c.cust_id=v.cust_id
      );

    insert into cust_contacts
    (
      cust_id
      ,contact_type
      ,contact_ord_num
      ,contact_value
      ,contact_base_yn
      ,contact_reg_dt
    )
    select
      cust_id
      ,2
      ,1
      ,dbms_random.string('l',1)||lower(dbms_random.string('x',dbms_random.value(2,9)))||'@'||dbms_random.string('l',dbms_random.value(3,9))||'.com'
      ,'N'
      ,to_date('20010110','YYYYMMDD')+dbms_random.value*5000
    from
      (
      select
        c.cust_id
      from customers c
        ,(select trunc(rownum*(1/(v_m_var2))) cust_id from customers where rownum<=v_adjV2) v
      where
        c.cust_id=v.cust_id
      );
    commit;

    merge into cust_contacts a
    using
    (
      select cust_id,max(contact_reg_dt) contact_reg_dt
      from cust_contacts
      group by cust_id
    ) b
    on (a.cust_id=b.cust_id and a.contact_reg_dt=b.contact_reg_dt)
    when matched then
      update set a.contact_base_yn='Y';
    commit;
  END CRE_CUST_CONTACTS;

  PROCEDURE CRE_ORDERS(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_adjV      number;   --생성 대상건수
    v_adjV1     number;
    v_adjV2     number;
  BEGIN
    DROP_CONST('ORDERS');
    execute immediate 'TRUNCATE TABLE ORDERS';

    dbms_random.seed(i_seed_val);

    v_adjV:=i_volume*20;

    v_adjV1:=trunc(v_adjV*0.995);
    v_adjV2:=v_adjV-v_adjV1;

    --기준일+5100일까지
    insert /*+ APPEND */ into orders
    (
      order_id
      ,order_dt
      ,cust_id
      ,order_status
      ,order_channel_type
      ,order_rct_emp_id
    )
    with cv_a as
      (
        select round(rnum/(m_val)) m
        from
        (
          select rnum,m_val
          from
            (
            select rownum+1 rnum,round(dbms_random.value(1,13)) m_val
            from
              customers
              ,(select rownum rnum from dual connect by rownum<=20)
            )
          where rownum<=v_adjV1
        )
      )
      ,cv_b as
      (
      select min(m) min_m,max(m) max_m,max(m)-min(m) diff_m from cv_a
      )
      ,cv_c as
      (
      select
        rownum rnum
        ,e.EMP_ID
        ,e.hire_date
      from employees e, departments d
      where d.dept_name='주문접수팀' and d.dept_id=e.dept_id
      order by EMP_ID
      )
      ,cv_d as
      (
      select max(rnum) max_rnum from cv_c
      )
    select
      order_id
      ,order_dt
      ,cust_id
      ,order_status
      ,order_channel_type
      ,case when channel>80 then e.EMP_ID end order_rct_emp_id
    from
      (
      select
        rownum order_id
        ,case when channel>80 then trunc(to_date('20010110','YYYYMMDD')+dbms_random.value(1,5100))+dbms_random.value(0.375,0.75) else to_date('20010110','YYYYMMDD')+dbms_random.value(1,5100) end order_dt
        ,cust_id
        ,case when status<=95 then '4' when status<=97 then '8' else '9' end order_status
        ,case when channel<=45 then '1' when channel<=80 then '2' else '3' end order_channel_type
        ,mod(v.channel+status+rownum,f.max_rnum)+1 emp_pno
        ,channel
      from
        (
        select
          cust_id
          ,trunc(dbms_random.value(1,100)) status
          ,trunc(dbms_random.value(1,100)) channel
        from
          (
          select
            least(greatest(trunc(m*i_volume/diff_m),1),i_volume) cust_id
          from
            cv_a a
            ,cv_b b
          )
        ) v
        ,cv_d f
      ) v
      ,cv_c e
    where
      emp_pno=e.rnum;
    commit;

    --기준일+5100일까지
    insert /*+ APPEND */ into orders
    (
      order_id
      ,order_dt
      ,cust_id
      ,order_status
      ,order_channel_type
      ,order_rct_emp_id
    )
    with cv_a as
      (
        select round(rnum/(m_val)) m
        from
        (
          select rnum,m_val
          from
            (
            select rownum+1 rnum,round(dbms_random.value(1,13)) m_val
            from
              customers
              ,(select rownum rnum from dual connect by rownum<=20)
            )
          where rownum<=v_adjV2
        )
      )
      ,cv_b as
      (
      select min(m) min_m,max(m) max_m,max(m)-min(m) diff_m from cv_a
      )
      ,cv_c as
      (
      select
        rownum rnum
        ,e.EMP_ID
        ,e.hire_date
      from employees e, departments d
      where d.dept_name='주문접수팀' and d.dept_id=e.dept_id
      order by EMP_ID
      )
      ,cv_d as
      (
      select max(rnum) max_rnum from cv_c
      )
    select
      order_id
      ,order_dt
      ,cust_id
      ,order_status
      ,order_channel_type
      ,case when channel>80 then e.EMP_ID end order_rct_emp_id
    from
      (
      select
        v_adjV1+rownum order_id
        ,case when channel>80 then trunc(to_date('20010110','YYYYMMDD')+dbms_random.value(5101,5125))+dbms_random.value(0.375,0.75) else to_date('20010110','YYYYMMDD')+dbms_random.value(5101,5125) end order_dt
        ,cust_id
        ,case when status<=24 then '1' when status<=44 then '2' when status<=74 then '3' when status<=94 then '4' when status<=99 then '8' else '9' end order_status
        ,case when channel<=45 then '1' when channel<=80 then '2' else '3' end order_channel_type
        ,mod(v.channel+status+rownum,f.max_rnum)+1 emp_pno
        ,channel
      from
        (
        select
          cust_id
          ,trunc(dbms_random.value(1,100)) status
          ,trunc(dbms_random.value(1,100)) channel
        from
          (
          select
            least(greatest(trunc(m*i_volume/diff_m),1),i_volume) cust_id
          from
            cv_a a
            ,cv_b b
          )
        ) v
        ,cv_d f
      ) v
      ,cv_c e
    where
      emp_pno=e.rnum;
    commit;
  END CRE_ORDERS;

  PROCEDURE CRE_ORDER_ITEMS(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_adjV      number;   --생성 대상건수
    v_adjV1     number;
    v_adjV2     number;

    v_product_id_min  number;
    v_product_id_max  number;
    v_1st_order_cnt number;
  BEGIN
    DROP_CONST('ORDER_ITEMS');
    execute immediate 'TRUNCATE TABLE ORDER_ITEMS';

    dbms_random.seed(i_seed_val);

    v_adjV:=trunc(i_volume*20*2.5);
    v_adjV1:=i_volume*20;

    select min(product_id),max(product_id) into v_product_id_min,v_product_id_max from products;

    insert /*+ APPEND */ into order_items
    (
    order_id
    ,order_seq_id
    ,product_id
    ,order_quantity
    ,order_price
    )
    select /*+ NO_MERGE(O) LEADING(O) USE_HASH(P) */
      order_id
      ,1
      ,o.product_id
      ,o.order_quantity
      ,o.order_quantity*p.product_price
    from
      (
      select
        order_id
        ,1
        ,least(greatest(trunc(trunc(ln(q*11),2)*(v_product_id_max-v_product_id_min)*0.04)+trunc(q,-2),v_product_id_min),v_product_id_max) product_id
        ,case when q<800 then 1 when q<900 then 2 when q<950 then 3 else trunc(dbms_random.value(1,10)) end order_quantity
        ,0
      from
        (
        select
          order_id
          ,trunc(dbms_random.value(1,1000)) q
        from orders
        )
      ) o
      ,products p
    where
      o.product_id=p.product_id;
    commit;

    select count(*) into v_1st_order_cnt from order_items;
    v_adjV1:=v_adjV-v_1st_order_cnt;

    insert /*+ APPEND */ into order_items
    (
    order_id
    ,order_seq_id
    ,product_id
    ,order_quantity
    ,order_price
    )
    select /*+ NO_MERGE(O) LEADING(O) USE_HASH(P) */
      o.order_id
      ,o.order_seq_id
      ,o.product_id
      ,o.order_quantity
      ,o.order_quantity*p.product_price
    from
      (
      select
        order_id
        ,(rank() over(partition by order_id order by rownum))+1 order_seq_id
        ,trunc(dbms_random.value(v_product_id_min,v_product_id_max)) product_id
        ,case when q<800 then 1 when q<900 then 2 when q<950 then 3 when q<985 then 4 else trunc(dbms_random.value(1,10)) end order_quantity
      from
        (
        select
          order_id
          ,trunc(dbms_random.value(1,1000)) q
        from
          (
          select
            order_id
            ,trunc(dbms_random.value(1,1000)) q
          from orders o
            ,(select rownum from dual connect by rownum<=9)
          order by q
          )
        where
          rownum<=v_adjV1
        )
      ) o
      ,products p
    where
      o.product_id=p.product_id;
    commit;
  END CRE_ORDER_ITEMS;

  PROCEDURE CRE_SHIPMENTS(i_seed_val in NUMBER)
  IS
    v_adjV      number;
    v_adjV1     number;
    v_adjV2     number;

    v_CORPORATION_id_min  number;
    v_CORPORATION_id_max  number;
    v_CORPORATION_id_cnt  number;
  BEGIN
    DROP_CONST('SHIPMENTS');
    execute immediate 'TRUNCATE TABLE SHIPMENTS';

    dbms_random.seed(i_seed_val);

    select min(CORPORATION_id),max(CORPORATION_id),count(*) into v_CORPORATION_id_min,v_CORPORATION_id_max,v_CORPORATION_id_cnt from CORPORATIONS where CORPORATION_type='3';

    insert /*+ APPEND */ into shipments
    (
      order_id
      ,cust_id
      ,ship_addr_ord_num
      ,shipment_status
      ,shipment_corporation_id
      ,tracking_number
      ,delivery_start_dt
      ,delivery_end_dt
    )
    select
      o.order_id
      ,o.cust_id
      ,trunc(dbms_random.value(1,nvl(sa.ship_addr_ord_num,1))) ship_addr_ord_num
      ,o.shipment_status
      ,o.shipment_corporation_id
      ,o.tracking_number
      ,o.delivery_start_dt
      ,trunc(o.delivery_start_dt)+trunc(dbms_random.value(1,3))+dbms_random.value(0.375,0.75) delivery_end_dt
    from
      (
      select
        order_id
        ,cust_id
        ,case when order_status in ('1','2') then '1' when order_status='3' then '2' when order_status in ('4','9') then '3' end shipment_status
        ,mod(trunc(dbms_random.value(v_corporation_id_min,v_corporation_id_max)),(v_corporation_id_cnt-trunc(dbms_random.value(0,v_corporation_id_cnt/5))))+v_corporation_id_min shipment_corporation_id
        ,to_char(o.order_dt,'YYYYMM') || dbms_random.string('X',10) tracking_number
        ,trunc(o.order_dt+dbms_random.value(1,3))+dbms_random.value(0.375,0.75) delivery_start_dt
      from orders o
      where o.order_status<>'8'
      ) o
      ,(
        select
          cust_id,max(ship_addr_ord_num) ship_addr_ord_num
        from shipment_addresses
        group by cust_id
      )  sa
    where
      o.cust_id=sa.cust_id(+);
    commit;
  END CRE_SHIPMENTS;

  FUNCTION CRE_HAN_STRING(i_min_string_size in number,i_max_string_size in number,i_type in varchar2) RETURN VARCHAR2
  IS
    v_g_han_char_o_cnt  number;
    v_string_size       number;
    v_string            varchar2(4000);

    v_min_string_size   number;
    v_max_string_size   number;
  BEGIN
    if i_type='1' then
      v_string:='';
      v_g_han_char_o_cnt:=g_han_char_o.count;
      v_min_string_size:=greatest(i_min_string_size,5);
      v_max_string_size:=least(i_max_string_size,1000);
  
--      FOR l_loop_cnt1 IN 1..6 LOOP
--        g_han_char_o(l_loop_cnt1+v_g_han_char_o_cnt).hchar:=' ';
--      END LOOP;
  
      v_g_han_char_o_cnt:=g_han_char_o.count;
      v_string_size:=trunc(dbms_random.value(v_min_string_size,v_max_string_size));
  
      FOR l_loop_cnt1 in 1..v_string_size LOOP
        v_string:=v_string||g_han_char_o(ceil(dbms_random.value*v_g_han_char_o_cnt)).hchar;
      END LOOP;
    else
      v_string:=g_han_char_w(ceil(dbms_random.value*g_weighted_char_counter)).hchar;
      FOR l_loop_cnt1 IN i_min_string_size..i_max_string_size-TRUNC(DBMS_RANDOM.VALUE(0.95,2.02)) LOOP
        v_string:=v_string||g_han_char_o(ceil(dbms_random.value*g_weighted_char_counter)).hchar;
      END LOOP;
      
    end if;

    return v_string;
  END CRE_HAN_STRING;

  PROCEDURE CRE_INQUIRIES(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_adjV      number;   --생성 대상건수
    v_cnt       number;   --생성 건수
    v_cursor    int;
    v_status    int;

    c_inq_type_number dbms_sql.varchar2_table;  --상품별(상품/배송/서비스/기타) 건수

    v_g_han_char_o_cnt  number;

    v_cust_id_min       number;
    v_cust_id_max       number;
    v_product_id_min       number;
    v_product_id_max       number;

    l_loop_cnt1 number;
  BEGIN
    DROP_CONST('INQUIRIES');
    execute immediate 'TRUNCATE TABLE INQUIRIES';

    dbms_random.seed(i_seed_val);

    v_adjV:=trunc(i_volume*0.063);
    v_cnt:=0;

    c_inq_type_number(1):=trunc(v_adjV*0.45);
    c_inq_type_number(2):=trunc(v_adjV*0.35);
    c_inq_type_number(3):=trunc(v_adjV*0.15);
    c_inq_type_number(4):=v_adjV-(c_inq_type_number(1)+c_inq_type_number(2)+c_inq_type_number(3));

    select min(cust_id),max(cust_id) into v_cust_id_min,v_cust_id_max from customers;
    select min(product_id),max(product_id) into v_product_id_min,v_product_id_max from products;

    --상품 문의
    insert /*+ APPEND */ into inquiries
    (
    cust_id
    ,inq_dt
    ,order_id
    ,emp_id
    ,product_id
    ,inq_type
    ,inq_status
    ,inq_q
    ,inq_a
    ,inq_satis_grade
    )
    with cv_a as
      (
        select round(rnum/(m_val)) m
        from
        (
          select rnum,m_val
          from
            (
            select rownum+1 rnum,round(dbms_random.value(1,13)) m_val
            from
              customers
              ,(select rownum rnum from dual connect by rownum<=15)
            )
          where rownum<=c_inq_type_number(1)
        )
      )
      ,cv_b as
      (
      select min(m) min_m,max(m) max_m,max(m)-min(m) diff_m from cv_a
      )
      ,cv_c as
      (
      select
        rownum rnum
        ,emp_id
        ,hire_date
      from
        (
        select
          e.emp_id
          ,e.hire_date
        from employees e, departments d
        where d.dept_name like '고객만족%팀' and d.dept_id=e.dept_id
        order by hire_date,EMP_ID
        )
      )
      ,cv_d as
      (
      select max(rnum) max_rnum from cv_c
      )
      ,cv_e as
      (
      select
        cust_id
        ,trunc(dbms_random.value(1,100)) inq_status
        ,trunc(dbms_random.value(1,100)) inq_satis_grade
      from
        (
        select
          least(greatest(trunc(m*i_volume/diff_m),1),i_volume) cust_id
        from
          cv_a a
          ,cv_b b
        )
      ) 
    select
        v.cust_id
        ,v.inq_dt
        ,NULL
        ,emp_id
        ,trunc(dbms_random.value(v_product_id_min,v_product_id_max)) product_id
        ,1
        ,inq_status
        ,cre_han_string(10,200,'1') inq_q
        ,case when inq_status='2' then cre_han_string(15,250,'1') end inq_a
        ,greatest(least(round(trunc(inq_satis_grade+(inq_dt-hire_date)/1000),0),5),1) inq_satis_grade
    from
      (
        select
          cust_id
          ,inq_dt
          ,emp_id
          ,hire_date
          ,case when inq_dt<=to_date('20010110','YYYYMMDD')+5100 then '2' when inq_status<=70 then '2' else '1' end inq_status
          ,inq_satis_grade
        from
          (
          select
            v.cust_id
            ,trunc(e.hire_date+dbms_random.value(1,to_date('20010110','YYYYMMDD')+5125-e.hire_date))+rnk+dbms_random.value(0.01,rnk/31)+dbms_random.value(0.375,0.75) inq_dt
            ,e.emp_id
            ,e.hire_date
            ,trunc(dbms_random.value(1,100)) inq_status
            ,trunc(dbms_random.value(1.5,6)) inq_satis_grade
          from
            (
            select 
              cust_id
              ,mod(v.inq_status+inq_satis_grade+rownum,f.max_rnum)+1 emp_pno
              ,rank() over(partition by cust_id order by rownum) rnk
            from 
              (
              select
                cust_id
                ,trunc(dbms_random.value(1,100)) inq_status
                ,trunc(dbms_random.value(1,100)) inq_satis_grade
              from
                (
                select
                  least(greatest(trunc(dbms_random.value(0,1)*m*i_volume/diff_m),1),i_volume) cust_id
                from
                  cv_a a
                  ,cv_b b
                )
              ) v
              ,cv_d f
            ) v
            ,cv_c e
          where
            emp_pno>=e.rnum
          )
      ) v
    ;
    commit;

    --배송 문의
    insert /*+ APPEND */ into inquiries
    (
    cust_id
    ,inq_dt
    ,order_id
    ,emp_id
    ,product_id
    ,inq_type
    ,inq_status
    ,inq_q
    ,inq_a
    ,inq_satis_grade
    )
    with 
      cv_c as
      (
      select
        rownum rnum
        ,emp_id
        ,hire_date
      from
        (
        select
          e.emp_id
          ,e.hire_date
        from employees e, departments d
        where d.dept_name like '고객만족%팀' and d.dept_id=e.dept_id
        order by hire_date,emp_id
        )
      )
      ,cv_d as
      (
      select max(rnum) max_rnum from cv_c
      )
    select 
        v.cust_id
        ,trunc(v.inq_dt)+dbms_random.value(0.375,0.75)
        ,order_id
        ,emp_id
        ,NULL
        ,2
        ,inq_status
        ,cre_han_string(10,200,'1') inq_q
        ,case when inq_status='2' then cre_han_string(15,250,'1') end inq_a
        ,greatest(least(round(trunc(inq_satis_grade+(inq_dt-hire_date)/1000),0),5),1) inq_satis_grade
    from
      (
        select /*+ NO_MERGE */ 
          cust_id
          ,inq_dt inq_dt
          ,order_id
          ,emp_id
          ,hire_date
          ,case when inq_dt<=to_date('20010110','YYYYMMDD')+5100 then '2' when inq_status<=80 then '2' else '1' end inq_status
          ,inq_satis_grade
        from
          (
          select
            v.cust_id
            ,trunc(order_dt+dbms_random.value(1,3)) inq_dt
            ,v.order_id
            ,e.emp_id
            ,e.hire_date
            ,trunc(dbms_random.value(1,100)) inq_status
            ,trunc(dbms_random.value(1.6,6)) inq_satis_grade
          from
            (
            select 
              order_id
              ,cust_id
              ,order_dt
              ,mod(v.inq_status+inq_satis_grade+rownum,f.max_rnum)+1 emp_pno
            from
              (
              select
                order_id
                ,cust_id
                ,order_dt
                ,trunc(dbms_random.value(1,100)) inq_status
                ,trunc(dbms_random.value(1,100)) inq_satis_grade
              from
                (
                select 
                   order_id
                   ,cust_id
                   ,order_dt
                from
                  (
                  select
                    order_id,cust_id,order_dt,rnum
                  from
                    (
                      select 
                        order_id,cust_id,order_dt,rownum rnum
                      from
                        (
                        select order_id,cust_id,order_dt,round(dbms_random.value(1,13)) m_val
                        from
                          orders
                          ,(select rownum rnum from dual connect by rownum<=3)
                        order by m_val
                        )
                      where rownum<=c_inq_type_number(2)
                    )
                  ) a
                )
              ) v
              ,cv_d f
            ) v
            ,cv_c e
          where
            emp_pno=e.rnum
          )
        order by cust_id,inq_dt
      ) v
    ;
    commit;

    --서비스/기타 문의
    for l_loop_cnt1 in 3..4 loop
      insert /*+ APPEND */ into inquiries
      (
      cust_id
      ,inq_dt
      ,order_id
      ,EMP_ID
      ,product_id
      ,inq_type
      ,inq_status
      ,inq_q
      ,inq_a
      ,inq_satis_grade
      )
      with cv_a as
        (
          select round(rnum/(m_val)) m
          from
          (
            select rnum,m_val
            from
              (
              select rownum+1 rnum,round(dbms_random.value(1,13)) m_val
              from
                customers
                ,(select rownum rnum from dual connect by rownum<=15-l_loop_cnt1)
              )
            where rownum<=c_inq_type_number(l_loop_cnt1)
          )
        )
        ,cv_b as
        (
        select min(m) min_m,max(m) max_m,max(m)-min(m) diff_m from cv_a
        )
        ,cv_c as
        (
        select
          rownum rnum
          ,EMP_ID
          ,hire_date
        from
          (
          select
            e.EMP_ID
            ,e.hire_date
          from employees e, departments d
          where d.dept_name like '고객만족%팀' and d.dept_id=e.dept_id
          order by hire_date,EMP_ID
          )
        )
        ,cv_d as
        (
        select max(rnum) max_rnum from cv_c
        )
      select
          v.cust_id
          ,v.inq_dt
          ,NULL
          ,EMP_ID
          ,NULL
          ,l_loop_cnt1
          ,inq_status
          ,cre_han_string(10,200,'1') inq_q
          ,case when inq_status='2' then cre_han_string(15,250,'1') end inq_a
          ,greatest(least(round(trunc(inq_satis_grade+(inq_dt-hire_date)/1000),0),5),1) inq_satis_grade
      from
        (
          select
            cust_id
            ,inq_dt
            ,EMP_ID
            ,hire_date
            ,case when inq_dt<=to_date('20010110','YYYYMMDD')+5100 then '2' when inq_status<=70 then '2' else '1' end inq_status
            ,inq_satis_grade
          from
            (
            select
              v.cust_id
              ,trunc(e.hire_date+dbms_random.value(1,trunc(to_date('20010110','YYYYMMDD')+5125-e.hire_date)))+rnk*2+dbms_random.value(0,rnk/31)+dbms_random.value(0.375,0.75) inq_dt
              ,e.EMP_ID
              ,e.hire_date
              ,trunc(dbms_random.value(1,100)) inq_status
              ,trunc(dbms_random.value(1.7,6)) inq_satis_grade
            from
              (
              select /*+ NO_MERGE */
                cust_id
                ,mod(v.inq_status+inq_satis_grade+rownum,f.max_rnum)+1 emp_pno
                ,rank() over(partition by cust_id order by rownum) rnk
              from
                (
                select
                  cust_id
                  ,trunc(dbms_random.value(1,100)) inq_status
                  ,trunc(dbms_random.value(1,100)) inq_satis_grade
                from
                  (
                  select
                    least(greatest(trunc(dbms_random.value(0,1)*m*i_volume/diff_m),1),i_volume) cust_id
                  from
                    cv_a a
                    ,cv_b b
                  )
                ) v
                ,cv_d f
              ) v
              ,cv_c e
            where
              emp_pno>=e.rnum
            )
        ) v
      ;
      commit;
    end loop;
  END CRE_INQUIRIES;

  PROCEDURE MAIN(i_seed_val in NUMBER,i_volume in NUMBER)
  IS
    v_volume  number;
  BEGIN
    dbms_random.seed(i_seed_val);
    v_volume:=i_volume;
    DEL_TABLES;
    CRE_CATEGORIES;
    CRE_CORPORATIONS(i_seed_val,v_volume);
    CRE_PRODUCTS(i_seed_val,v_volume);
    CRE_CUSTOMERS(i_seed_val,v_volume);
    CRE_DEPARTMENTS;
    CRE_EMPLOYEES(i_seed_val,v_volume);
    CRE_CUST_CONTACTS(i_seed_val,v_volume);
    CRE_SHIPMENT_ADDRESSES(i_seed_val,v_volume);
    CRE_CUST_CONTACTS(i_seed_val,v_volume);
    CRE_ORDERS(i_seed_val,v_volume);
    CRE_ORDER_ITEMS(i_seed_val,v_volume);
    CRE_INQUIRIES(i_seed_val,v_volume);
    CRE_SHIPMENTS(i_seed_val);
    CRE_CONST;
  END MAIN;

BEGIN
  initialize;
END PKG_DATA_GEN;
/

