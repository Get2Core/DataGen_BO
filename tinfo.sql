--
-- TINFO.sql
-- 내  용 : Table및 그 Table에 속한 INDEX 및 Column에 대한 상세 정보 출력
-- 작성자 : 김철각
--

SET VERIFY OFF
SET TIMING OFF
SET FEEDBACK OFF
SET LINESIZE 150
SET PAGESIZE 10000
SET SERVEROUTPUT ON
SET TERMOUT ON

accept schname prompt 'Enter schema name : '
accept tname prompt 'Enter table name  : '

variable	v_schema	varchar2(30)
variable	v_tname		varchar2(30)

exec :v_schema:=upper(trim('&schname'))
exec :v_tname:=upper(trim('&tname'))

COL "Partition Column Name" FORMAT A20
COL TAB_INFO heading "TABLE NAME|TABLESPACE NAME" FORMAT A30
COL BLK_INFO heading "BLOCKS|EMP.B" FORMAT A8
COL AVG_ROW_LEN heading "AVG|ROW|LEN" FORMAT 999
COL AVG_SPACE heading "AVG|SPACE" FORMAT 9999
COL CHAIN_CNT heading "CHAIN|CNT" FORMAT 9999
COL INEXT heading "IEXT/NEXT|MIN/MAX" FORMAT A10
COL TRAN heading "INITRAN|MAXTRAN" FORMAT A7
COL PCT heading "PCTFREE|PCTUSED|PCTINCR" FORMAT A9
COL FREE heading "FLst/|FGrp" FORMAT A5
COL DEGREE FORMAT A3
COL NUM_ROWS FORMAT 99999999999999

COL COMMENTS FORMAT A80

SELECT :v_schema || '.' || :v_tname || ' (' || COMMENTS || ')' "Table Comments"
FROM   all_tab_comments
WHERE  owner = :v_schema
AND    table_name = :v_tname
AND    COMMENTS IS NOT NULL
/

SELECT
    TABLE_NAME
    ,PARTITIONING_TYPE
    ,SUBPARTITIONING_TYPE
--    ,STATUS
    ,PARTITION_COUNT
    ,DEF_SUBPARTITION_COUNT
FROM ALL_PART_TABLES
WHERE  owner = :v_schema
AND    table_name = :v_tname
/

SELECT
    'PARTITION' TYP
    ,COLUMN_NAME "Partition Column Name"
    ,COLUMN_POSITION "Position"
FROM   ALL_PART_KEY_COLUMNS
WHERE  OWNER = :v_schema
AND    NAME = :v_tname
UNION ALL
SELECT
    'SUB PARTITION' TYP
    ,COLUMN_NAME "Partition Column Name"
    ,COLUMN_POSITION "Position"
FROM   ALL_SUBPART_KEY_COLUMNS
WHERE  OWNER = :v_schema
AND    NAME = :v_tname
ORDER  BY 1,3
/

SET SERVEROUTPUT ON
DECLARE
	CURSOR CUR_PART_VALUE IS
		SELECT
			PARTITION_POSITION
			,PARTITION_NAME
			,HIGH_VALUE
		FROM
			ALL_TAB_PARTITIONS
		WHERE
			TABLE_OWNER=:v_schema
			AND TABLE_NAME=:v_tname
		ORDER BY
			PARTITION_POSITION;

	V_PARTITION_POSITION NUMBER;
	V_PARTITION_NAME	VARCHAR2(30);
	V_HIGH_VALUE		VARCHAR2(4000);
BEGIN
	SYS.DBMS_OUTPUT.ENABLE(1000000);
	OPEN CUR_PART_VALUE;
	LOOP
		FETCH CUR_PART_VALUE INTO V_PARTITION_POSITION,V_PARTITION_NAME,V_HIGH_VALUE;
		EXIT WHEN CUR_PART_VALUE%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE(V_PARTITION_POSITION || ',' || V_PARTITION_NAME || ':' || V_HIGH_VALUE);
	END LOOP;
	CLOSE CUR_PART_VALUE;
END;
/

SELECT table_name || CHR( 10 ) || tablespace_name AS "TAB_INFO" ,
       round(num_rows,0) num_rows ,
       avg_row_len ,
       blocks || CHR( 10 ) || empty_blocks AS "BLK_INFO" ,
       TRIM( TO_CHAR( degree ) ) degree ,
       avg_space ,
       chain_cnt ,
       pct_free || '/' || pct_used || '/' || pct_increase pct ,
       ini_trans || '/' ||max_trans tran ,
       decode( SIGN( FLOOR( initial_extent/1024/1024 ) ) , 1 , ROUND( initial_extent/1024/1024 , 1 ) ||'M' , ROUND( initial_extent/1024 ) ||'K' ) || '/' || decode( SIGN( FLOOR( next_extent/1024/1024 ) ) , 1 , ROUND( next_extent/1024/1024 , 1 ) ||'M' , ROUND( next_extent/1024 ) ||'K' ) || CHR( 10 ) || min_extents ||'/' || decode( max_extents , 2147483645 , 'UNLIMIT' , max_extents ) inext ,
       FREELISTS || '/' || freelist_groups free
FROM   all_tables AT
WHERE  owner = :v_schema
AND    table_name = :v_tname
UNION  ALL
SELECT table_name || ' [OBJ]' || CHR( 10 ) || tablespace_name AS "TAB_INFO" ,
       round(num_rows,0) num_rows ,
       avg_row_len ,
       blocks || CHR( 10 ) || empty_blocks AS "BLK_INFO" ,
       TRIM( TO_CHAR( degree ) ) degree ,
       avg_space ,
       chain_cnt ,
       pct_free || '/' || pct_used || '/' || pct_increase pct ,
       ini_trans || '/' ||max_trans tran ,
       decode( SIGN( FLOOR( initial_extent/1024/1024 ) ) , 1 , ROUND( initial_extent/1024/1024 , 1 ) ||'M' , ROUND( initial_extent/1024 ) ||'K' ) || '/' || decode( SIGN( FLOOR( next_extent/1024/1024 ) ) , 1 , ROUND( next_extent/1024/1024 , 1 ) ||'M' , ROUND( next_extent/1024 ) ||'K' ) || CHR( 10 ) || min_extents ||'/' || decode( max_extents , 2147483645 , 'UNLIMIT' , max_extents ) inext ,
       FREELISTS || '/' || freelist_groups free
FROM   all_object_tables aot
WHERE  owner = :v_schema
AND    table_name = :v_tname
AND    tablespace_name IS NOT NULL
UNION  ALL
SELECT at.table_name || ':' || atp.partition_name || CHR(10) || atp.tablespace_name  AS "TAB_INFO" ,
       round(atp.num_rows,0) num_rows ,
       atp.avg_row_len ,
       atp.blocks || CHR( 10 ) || atp.empty_blocks AS "BLK_INFO" ,
       TRIM(TO_CHAR( at.degree )) degree ,
       atp.avg_space ,
       atp.chain_cnt ,
       atp.pct_free || '/' || atp.pct_used || '/' || atp.pct_increase pct ,
       atp.ini_trans || '/' ||atp.max_trans tran ,
       decode( SIGN( FLOOR( atp.initial_extent/1024/1024 ) ) , 1 , ROUND( atp.initial_extent/1024/1024 , 1 ) ||'M' , ROUND( atp.initial_extent/1024 ) ||'K' ) || '/' || decode( SIGN( FLOOR( atp.next_extent/1024/1024 ) ) , 1 , ROUND( atp.next_extent/1024/1024 , 1 ) ||'M' , ROUND( atp.next_extent/1024 ) ||'K' ) || CHR( 10 ) || atp.min_extent ||'/' || decode( atp.max_extent , 2147483645 , 'UNLIMIT' , atp.max_extent ) inext ,
       atp.freelists || '/' || atp.freelist_groups free
FROM   all_tables AT ,
       all_tab_partitions atp
WHERE  atp.table_owner = at.owner
AND    atp.table_name = at.table_name
AND    atp.tablespace_name IS NOT NULL
AND    at.owner = :v_schema
AND    at.table_name = :v_tname
ORDER  BY 1
/


COL IND_INFO heading "INDEX NAME|TABLESPACE NAME" FORMAT A40
COL ALB_ADB heading "ALB/ADB" FORMAT A10
COL CLUSTERING_FACTOR heading "CLUSTERING|FACTOR"
COL BLK_INFO heading "LEAF_BLK|BLEVEL" FORMAT A8
COL NUM_ROWS heading "NUM_ROWS|DISTINCT_KEYS" FORMAT A15
COL LAST_ANALYZED heading "LAST_ANALYZED" FORMAT A11

SELECT index_name || ' (' || SUBSTR( uniqueness , 1 , 1 ) || ')' || CHR( 10 ) || tablespace_name || '(' || status || ')' ind_info ,
       to_char(LAST_ANALYZED,'YYYY.MM.DD') || CHR(10) || to_char(LAST_ANALYZED,'HH24:MI') LAST_ANALYZED ,
       lpad(round(num_rows,0),14,' ')  || CHR(10) || lpad(distinct_keys,14,' ') NUM_ROWS,
       clustering_factor ,
       leaf_blocks || CHR( 10 ) || blevel AS "BLK_INFO" ,
       avg_leaf_blocks_per_key || '/' ||avg_data_blocks_per_key alb_adb ,
       ini_trans || '/' ||max_trans tran ,
       decode( SIGN( FLOOR( initial_extent/1024/1024 ) ) , 1 , ROUND( initial_extent/1024/1024 , 1 ) ||'M' , ROUND( initial_extent/1024 ) ||'K' ) || '/' || decode( SIGN( FLOOR( next_extent/1024/1024 ) ) , 1 , ROUND( next_extent/1024/1024 , 1 ) ||'M' , ROUND( next_extent/1024 ) ||'K' ) || CHR( 10 ) || min_extents ||'/' || decode( max_extents , 2147483645 , 'UNLIMIT' , max_extents ) inext ,
       FREELISTS || '/' || freelist_groups free
FROM   all_indexes
WHERE  table_owner = :v_schema
AND    table_name = :v_tname
UNION  ALL
SELECT /*+ ORDERED FIRST_ROWS */
       ai.index_name || ':' || aip.partition_name || ' (' || SUBSTR( ai.uniqueness , 1 , 1 ) || ')' || CHR( 10 ) || aip.tablespace_name || '(' || aip.status || ')' ind_info ,
       to_char(aip.LAST_ANALYZED,'YYYY.MM.DD') || CHR(10) || to_char(aip.LAST_ANALYZED,'HH24:MI') LAST_ANALYZED ,
       lpad(round(aip.num_rows,0),14,' ')  || CHR(10) || lpad(aip.distinct_keys,14,' ') NUM_ROWS,
       aip.clustering_factor ,
       aip.leaf_blocks || CHR( 10 ) || aip.blevel AS "BLK_INFO" ,
       aip.avg_leaf_blocks_per_key || '/' ||aip.avg_data_blocks_per_key alb_adb ,
       aip.ini_trans || '/' ||aip.max_trans tran ,
       decode( SIGN( FLOOR( aip.initial_extent/1024/1024 ) ) , 1 , ROUND( aip.initial_extent/1024/1024 , 1 ) ||'M' , ROUND( aip.initial_extent/1024 ) ||'K' ) || '/' || decode( SIGN( FLOOR( aip.next_extent/1024/1024 ) ) , 1 , ROUND( aip.next_extent/1024/1024 , 1 ) ||'M' , ROUND( aip.next_extent/1024 ) ||'K' ) || CHR( 10 ) || aip.min_extent ||'/' || decode( aip.max_extent , 2147483645 , 'UNLIMIT' , max_extent ) inext ,
       aip.freelists || '/' || aip.freelist_groups free
FROM   (
        SELECT degree ,
               uniqueness ,
               owner ,
               index_name ,
               tablespace_name  ,
               index_type
        FROM   all_indexes
        WHERE  table_owner=:v_schema
        AND    table_name=:v_tname
        AND    tablespace_name IS NULL
       ) ai ,
       all_ind_partitions aip
WHERE  ai.index_name=aip.index_name
AND    ai.owner=aip.index_owner
AND    aip.tablespace_name IS NOT NULL
ORDER  BY 1
/

--col	"TABLE"		form	a30
col	"INDEX"		form	a45
col	"COLUMN"	form	a75
col "LAST ANALYZED" form a20

--SELECT decode( rnum , 1 , table_name ) "TABLE" ,
--       decode( col_position , 1 , index_name || '(' || decode( uniq , 1 , 'U' , 2 , 'N' ) || ':' || index_type || ')' ) "INDEX" ,
--       decode(descend,'ASC',column_name,column_name || '[' || descend || ']') "COLUMN"
--FROM   (
--        SELECT table_name ,
--               index_name ,
--               column_name ,
--               col_position ,
--               uniq ,
--               index_type ,
--               descend ,
--               ROWNUM rnum
--        FROM   (
--               SELECT DISTINCT b.table_name ,
--                       decode( SUBSTR( a.uniqueness , 1 , 1 ) , 'U' , 1 , 'N' , 2 ) uniq ,
--                       b.index_name ,
--                       b.column_position col_position ,
--                       b.column_name ,
--                       a.index_type ,
--                       descend
--                FROM   all_indexes a ,
--                       all_ind_columns b
--                WHERE  a.table_name=:v_tname
--                AND    a.index_name=b.index_name
--                AND    a.owner=b.index_owner
--                AND    a.table_owner=:v_schema --and a.funcidx_status is NULL
--                ORDER BY
--                    uniq,index_name,col_position
--               )
--       )
--/
SELECT index_name || '(' || decode( uniq , 1 , 'U' , 2 , 'N' ) || ':' || index_type || ')' "INDEX"
       ,decode(descend,'ASC',comp_col_name,comp_col_name || '[' || descend || ']') "COLUMN"
--       ,to_char(last_analyzed,'YYYY.MM.DD HH24:MI:SS') "LAST ANALYZED"
FROM
    (
    SELECT
        table_name
        ,uniq
        ,index_name
        ,col_position
        ,column_name
        ,index_type
        ,descend
        ,substr(SYS_CONNECT_BY_PATH(column_name, ','),2) comp_col_name
        ,column_max
        ,rownum rnum
        ,last_analyzed
    FROM
        (
        SELECT b.table_name ,
               decode( SUBSTR( a.uniqueness , 1 , 1 ) , 'U' , 1 , 'N' , 2 ) uniq ,
               b.index_name ,
               b.column_position col_position ,
               b.column_name ,
               a.index_type ,
               a.last_analyzed,
               descend,
               LAG(column_position) over (partition by b.index_name order by column_position) column_lag ,
               MAX(column_position) over (partition by b.index_name) column_max,
               RANK() over (partition by b.index_owner,b.index_name order by b.column_position) rnum
        FROM   all_indexes a ,
               all_ind_columns b
        WHERE  a.table_name=:v_tname
        AND    a.index_name=b.index_name
        AND    a.owner=b.index_owner
        AND    a.table_owner=:v_schema
        ORDER BY
            uniq,index_name,col_position
        )
    START WITH
        column_lag IS NULL AND RNUM=1
    CONNECT BY PRIOR col_position = column_lag and PRIOR index_name=index_name
    )
WHERE
    col_position = column_max
/

SET SERVEROUTPUT ON
DECLARE


	CURSOR CUR_IND_COL IS
		SELECT
		    a.index_name
            , c.column_expression
            , c.column_position
        FROM   all_indexes a ,
               all_ind_columns b ,
               all_ind_expressions c
        WHERE  a.table_name=:v_tname
        AND    a.index_name=b.index_name
        AND    a.owner=b.index_owner
        AND    a.table_owner=:v_schema
        and    a.index_name=c.index_name
        and    a.owner=c.index_owner
        and    b.column_position=c.column_position
        ORDER BY a.index_name,c.column_position;

	V_COLUMN_POSITION NUMBER;
	V_INDEX_NAME	VARCHAR2(30);
	V_COLUMN_NAME   VARCHAR2(200);
BEGIN
	SYS.DBMS_OUTPUT.ENABLE(1000000);
	OPEN CUR_IND_COL;

	LOOP
		FETCH CUR_IND_COL INTO V_INDEX_NAME,V_COLUMN_NAME,V_COLUMN_POSITION;
		EXIT WHEN CUR_IND_COL%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE('-FBI COLUMN : ' || V_INDEX_NAME || ':' || V_COLUMN_POSITION || ':' || V_COLUMN_NAME);
	END LOOP;
	CLOSE CUR_IND_COL;
END;
/

COL TABLE_NAME FORMAT A20
COL COLUMN_NAME FORMAT A27
COL DATA_TYPE FORMAT A13
COL LV FORMAT A18
COL HV FORMAT A18
COL DPDS HEADING "PREC|SCALE" FORMAT A4
COL DATA_LENGTH HEADING "DATA|LEN" FORMAT 9999
COL NUM_BUCKETS HEADING "NUMBER|BUCKET" FORMAT 9999
COL NUM_DISTINCT HEADING "NUMBER|DISTINCT" FORMAT 99999999
COL SAMPLE_SIZE HEADING "SAMPLE|SIZE" FORMAT 999999
COL AVG_LEN FORMAT 999999
COL PCTFU FORMAT A5
COL FREE FORMAT A5
COL PCT FORMAT 999
COL COMMENTS FORM A25

SELECT a.column_name ,
       a.data_type ,
       a.data_length ,
       decode( a.data_precision || '/' || a.data_scale , '/' , NULL , a.data_precision || '/' || a.data_scale ) dpds ,
       a.nullable nn ,
       a.num_distinct ,
       round(a.density,5) density ,
       round(a.num_nulls,0) num_nulls,
       a.avg_col_len avg_len,
       a.num_buckets ,
       a.sample_size ,
       b.comments
FROM   all_tab_columns a ,
       all_col_comments b
WHERE  a.owner = :v_schema
AND    a.table_name = :v_tname
AND    a.owner = b.owner
AND    a.table_name = b.table_name
AND    a.column_name = b.column_name
ORDER BY a.COLUMN_ID
/

COL "COLUMN REFERENCE" FORMAT A120
SET HEAD OFF

--prompt
--accept rcon 	prompt 'Press Enter to view referential relation keys : '

select
	rpad('[' || replace(trim(c1),' ',',') || ']>',65,'-') || '[' || replace(trim(c2),' ',',') || ']' as "COLUMN REFERENCE"
from
	(
	select
		(
		select
			MAX(DECODE(dcc.position, 1, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 2, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 3, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 4, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 5, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 6, dcc.column_name)) || ' '
		from all_cons_columns dcc
		where
			dcc.owner=dc.owner
			and dcc.constraint_name=dc.constraint_name
		) c1,
		(
		select
			r_owner || '.' ||
			MAX(table_name) || '.' ||
			MAX(DECODE(dcc.position, 1, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 2, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 3, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 4, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 5, dcc.column_name)) || ' ' ||
			MAX(DECODE(dcc.position, 6, dcc.column_name)) || ' '
		from all_cons_columns dcc
		where
			dcc.owner=dc.r_owner
			and dcc.constraint_name=dc.r_constraint_name
		) c2
	from all_constraints dc
	where
		owner=:v_schema
		and table_name=:v_tname
		and constraint_type='R'
	order by c1
	)
/

select ' ' as "COLUMN REFERENCE" from dual
/

declare
	cur_tab_cnt		number;
	v_tabcntnum 	number;
	ignore          number;
	v_sql			varchar2(4000);
	type typ_sql is table of varchar2(1000) INDEX BY BINARY_INTEGER;
	tbl_result		dbms_sql.varchar2_table;
	i 				binary_integer;
begin
--	if 'rcon' is NULL then
	if 0=0 then
		cur_tab_cnt := dbms_sql.open_cursor;
		sys.dbms_output.enable(20000);
		dbms_sql.parse(cur_tab_cnt,'select count(*) from all_tables where table_name in (''FND_TABLES'',''FND_FOREIGN_KEYS'',''FND_FOREIGN_KEY_COLUMNS'')',1);
		dbms_sql.define_column(cur_tab_cnt,1,v_tabcntnum);
		ignore:=sys.dbms_sql.execute(cur_tab_cnt);
		ignore:=sys.dbms_sql.fetch_rows(cur_tab_cnt);
		dbms_sql.column_value(cur_tab_cnt,1,v_tabcntnum);
		if v_tabcntnum=3 then
			dbms_sql.parse(cur_tab_cnt,'select count(*) from apps.fnd_tables ft,apps.fnd_foreign_keys ffk where ft.table_name=:b1 and ft.application_id=ffk.application_id and ft.table_id=ffk.table_id',1);
			dbms_sql.bind_variable(cur_tab_cnt,':b1',:v_tname);
			dbms_sql.define_column(cur_tab_cnt,1,v_tabcntnum);
			ignore:=sys.dbms_sql.execute(cur_tab_cnt);
			ignore:=sys.dbms_sql.fetch_rows(cur_tab_cnt);
			dbms_sql.column_value(cur_tab_cnt,1,v_tabcntnum);

			v_sql:=' ' ||
					'select ' ||
	--				'	rpad(''['' || replace(trim(c1),'' '','','') || '']>---'',80,'' '') || lpad(''---['' || replace(trim(c2),'' '','','') || '']'',80,'' '') as "COLUMN REFERENCE" ' ||
					'	''['' || replace(trim(c1),'' '','','') || '']>-'' || ''-['' || replace(trim(c2),'' '','','') || '']'' as "COLUMN REFERENCE" ' ||
					'from ' ||
					'	( ' ||
					'	select ' ||
					'		( ' ||
					'		select ' ||
					'			MAX(DECODE(ffkc.foreign_key_sequence, 1, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(ffkc.foreign_key_sequence, 2, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(ffkc.foreign_key_sequence, 3, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(ffkc.foreign_key_sequence, 4, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(ffkc.foreign_key_sequence, 5, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(ffkc.foreign_key_sequence, 6, fc.column_name)) || '' '' ' ||
					'		from ' ||
					'			apps.fnd_foreign_key_columns ffkc ' ||
					'			,apps.fnd_columns	fc ' ||
					'		where ' ||
					'			ffk.application_id=ffkc.application_id ' ||
					'			and ffk.table_id=ffkc.table_id ' ||
					'			and ffk.foreign_key_id=ffkc.foreign_key_id ' ||
					'			and ffkc.application_id=fc.application_id ' ||
					'			and ffkc.table_id=fc.table_id ' ||
					'			and ffkc.column_id=fc.column_id ' ||
					'		) c1, ' ||
					'		( ' ||
					'		select ' ||
					'			MAX(ft.table_name) || ''.'' || ' ||
					'			MAX(DECODE(fpkc.primary_key_sequence, 1, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(fpkc.primary_key_sequence, 2, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(fpkc.primary_key_sequence, 3, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(fpkc.primary_key_sequence, 4, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(fpkc.primary_key_sequence, 5, fc.column_name)) || '' '' || ' ||
					'			MAX(DECODE(fpkc.primary_key_sequence, 6, fc.column_name)) || '' '' ' ||
					'		from ' ||
					'			apps.fnd_primary_key_columns fpkc ' ||
					'			,apps.fnd_columns	fc ' ||
					'			,apps.fnd_tables	ft ' ||
					'		where ' ||
					'			ffk.primary_key_id=fpkc.primary_key_id ' ||
					'			and fpkc.application_id=fc.application_id ' ||
					'			and fpkc.table_id=fc.table_id ' ||
					'			and fpkc.column_id=fc.column_id ' ||
					'			and ft.application_id=fc.application_id ' ||
					'			and ft.table_id=fc.table_id ' ||
					'		) c2 ' ||
					'	from ' ||
					'		apps.fnd_tables ft ' ||
					'		,apps.fnd_foreign_keys ffk ' ||
					'	where ' ||
					'		ft.table_name=:b1 ' ||
					'       and ft.table_id = ffk.table_id ' ||
					'		and ft.application_id=ffk.application_id ' ||
					'		and ft.table_id=ffk.table_id ' ||
					'	order by c1 ' ||
					'	) ';
			dbms_sql.parse(cur_tab_cnt,v_sql,1);
			dbms_sql.bind_variable(cur_tab_cnt,':b1',:v_tname);
			dbms_sql.define_array(cur_tab_cnt,1,tbl_result,1000,1);
			ignore:=sys.dbms_sql.execute(cur_tab_cnt);
			ignore:=sys.dbms_sql.fetch_rows(cur_tab_cnt);
			dbms_sql.column_value(cur_tab_cnt,1,tbl_result);
			i:=1;
			for i in 1..v_tabcntnum loop
				dbms_output.put_line(tbl_result(i));
			end loop;
		end if;

		dbms_sql.close_cursor(cur_tab_cnt);
	end if;
end;
/

SET HEAD ON

COL "TRIGGER NAME" FORMAT A30
COL "TRIGGER TYPE" FORMAT A16
COL "TRIGGERING EVENT" FORMAT A40
COL status			FORMAT A8

select
	trigger_name	"TRIGGER NAME"
	,trigger_type 	"TRIGGER TYPE"
	,TRIGGERING_EVENT	"TRIGGERING EVENT"
	,status
from
	all_triggers
where
	table_owner = :v_schema
	and table_name = :v_tname
	and BASE_OBJECT_TYPE = 'TABLE'
/

--prompt
--accept con 	prompt 'Press Enter to view real row count : '
--
--declare
--	cur_tab_cnt		number;
--	v_tabcntnum 	number;
--	ignore          number;
--begin
--	cur_tab_cnt := dbms_sql.open_cursor;
--	sys.dbms_output.enable(1000);
--	if '&con' is NULL then
--		DBMS_SQL.PARSE(cur_tab_cnt,'select count(*) from ' || :v_schema || '.' || :v_tname,1);
--		dbms_sql.define_column(cur_tab_cnt,1,v_tabcntnum);
--		ignore:=sys.dbms_sql.execute(cur_tab_cnt);
--		ignore:=sys.dbms_sql.fetch_rows(cur_tab_cnt);
--		dbms_sql.column_value(cur_tab_cnt,1,v_tabcntnum);
--		dbms_output.put_line('---------------------------------------------------------------------------------------------');
--		dbms_output.put('Current Row Number    : ');
--		dbms_output.put_line(v_tabcntnum);
--	end if;
----	DBMS_SQL.PARSE(cur_tab_cnt,'select num_rows from all_tables where owner=' || chr(39) || :v_schema || chr(39) || ' and table_name=' || chr(39) || :v_tname || chr(39),1);
--	DBMS_SQL.PARSE(cur_tab_cnt,'select at.num_rows num_rows from all_tables at where at.owner=' || chr(39) || :v_schema || chr(39) || ' and at.table_name=' || chr(39) || :v_tname || chr(39) || ' union all select aot.num_rows num_rows from all_object_tables aot where aot.owner=' || chr(39) || :v_schema || chr(39) || ' and aot.table_name=' || chr(39) || :v_tname || chr(39),1);
--	dbms_sql.define_column(cur_tab_cnt,1,v_tabcntnum);
--	ignore:=sys.dbms_sql.execute(cur_tab_cnt);
--	ignore:=sys.dbms_sql.fetch_rows(cur_tab_cnt);
--	dbms_sql.column_value(cur_tab_cnt,1,v_tabcntnum);
--	dbms_output.put('Statistics Row Number : ');
--	dbms_output.put_line(v_tabcntnum);
--	dbms_sql.close_cursor(cur_tab_cnt);
--end;
--/
--
--prompt

COL NO FORMAT A10
COL SAVETIME FORMAT A20
COL ROWCNT FORMAT A15
COL BLKCNT FORMAT A11
COL AVGRLN FORMAT A7

SELECT
    'History #' || ROWNUM NO
    ,SAVETIME
    ,TO_CHAR(ROWCNT,'FM999,999,999,999') ROWCNT
    ,TO_CHAR(BLKCNT,'FM999,999,999') BLKCNT
    ,TO_CHAR(AVGRLN,'FM999,999') AVGRLN
FROM
    (
    SELECT
        U.NAME      USER_NAME
        ,OT.NAME    TABLE_NAME
        ,TO_CHAR(T.SAVTIME,'YYYY.MM.DD HH24:MI:SS') SAVETIME
        ,T.ROWCNT
        ,T.BLKCNT
        ,T.AVGRLN
    FROM
        SYS.USER$ U
        ,SYS.OBJ$ OT
        ,SYS.WRI$_OPTSTAT_TAB_HISTORY T
    WHERE
        U.NAME=:v_schema
        AND OT.NAME=:v_tname
        AND OT.OWNER# = U.USER#
        AND OT.TYPE# IN (2,19)
        AND OT.OBJ# = T.OBJ#
    ORDER BY
        OT.NAME
        ,T.SAVTIME DESC
    )
WHERE
    ROWNUM<=5;

SET HEAD OFF
select 'Last Analyzed Day : ' || nvl(to_char(LAST_ANALYZED,'YYYY.MM.DD HH24:MI:SS'),'NOT PERFORMED') from all_tables where owner=:v_schema and table_name=:v_tname
union all
select 'Current Time      : ' || to_char(sysdate,'YYYY.MM.DD HH24:MI:SS') from dual;

SET VERIFY ON
SET TIMING ON
SET FEEDBACK ON
SET SERVEROUTPUT OFF
SET HEAD ON
SET LINESIZE 100
