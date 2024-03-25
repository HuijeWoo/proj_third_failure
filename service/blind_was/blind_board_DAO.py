from blindlogging import *
import pymysql
from flask import *

# DB 연결
def db_connect() :
    db = pymysql.connect(
        user = 'root',
        password = '12341234',
        host = 'blind.cq83gr1p9r0f.ap-northeast-1.rds.amazonaws.com',
        db = 'blind',
        charset = 'utf8',
        autocommit = True
    )

    return db

# board 테이블 전체 SELECT (메인화면 게시글 전체 출력)
def selectBoard() :
    if session :
        id = session['login_info'].get('id')
        board_DAO_logger.info(f"{id}: blind_board_DAO.selectBoard()에 진입")
    else :
        id = "guest"
    result = []
    try :
        con = db_connect()
        cursor = con.cursor(cursor=pymysql.cursors.DictCursor)
        sql_select = 'SELECT * FROM board ORDER BY date_time DESC ;'
        cursor.execute(sql_select)
        result = cursor.fetchall()

        cursor.close()
        con.close()

    except Exception as e :
        board_DAO_logger.info(f"{id}: blind_board_DAO에서 예외 발생({e})")

    board_DAO_logger.info(f"{id}: blind_board_DAO.selectBoard()종료")    
    return result

# board 테이블 SELECT (글 상세보기)
def selectBoardByIdx(idx) :
    if session :
        id = session['login_info'].get('id')
    else:
        id = "guest"
    board_DAO_logger.info(f"{id}: blind_bloard_DAO.selectBoardByIdx({idx})")
    result = []
    try :
        con = db_connect()
        cursor = con.cursor(cursor=pymysql.cursors.DictCursor)

        sql_select = 'SELECT * FROM board WHERE idx = %s'
        cursor.execute(sql_select, idx)
        result = cursor.fetchone()

        cursor.close()
        con.close()

    except Exception as e :
        board_DAO_logger.info(f"{id}: blind_board_DAO.selectBoardById()에서 예외 발생({e})")

    board_DAO_logger.info(f"{id}: blind_board_DAO.selectBoardById()종료")     
    return result

# board 테이블 INSERT
def insertBoard(title, contents, id, name) :
    con = db_connect()
    cursor = con.cursor()
    sql_insert = 'INSERT INTO board (title, contents, id, name) values (%s, %s, %s, %s)'

    result_num = cursor.execute(sql_insert, (title, contents, id, name))
    
    cursor.close()
    con.close()

    return result_num

# board 테이블 UPDATE
def updateBoard(idx, title, contents, id, name) :
    board_DAO_logger.info(f"{session['login_info'].get('id')}: blind_board_DAO.updateBoard()에 진입")
    try :       
        con = db_connect()
        cursor = con.cursor()
        sql_update = 'UPDATE board SET title = %s, contents = %s, id = %s, name = %s WHERE idx = %s'

        result_num = cursor.execute(sql_update, (title, contents, id, name, idx))
        
        cursor.close()
        con.close()

    except Exception as e :
        board_DAO_logger.info(f"{session['login_info'].get('id')}: blind_board_DAO()에서 예외 발생({e})")

    board_DAO_logger.info(f"{session['login_info'].get('id')}: blind_board_DAO.updateBoard()종료")         
    return result_num

# board 테이블 DELETE
def deleteBoardByIdx(idx) :
    board_DAO_logger.info(f"{session['login_info'].get('id')}: blind_board_DAO.deleteBoardIdx()에 진입")
    try :      
        con = db_connect()
        cursor = con.cursor()

        sql_delete = 'DELETE FROM board WHERE idx = %s'
        result_num = cursor.execute(sql_delete, idx)

        cursor.close()
        con.close()
    except Exception as e :
        board_DAO_logger.info(f"{session['login_info'].get('id')}: blind_board_deleteBoardByIdx()에서 예외 발생{e}")

    board_DAO_logger.info(f"{session['login_info'].get('id')}: blind_board_deleteBoardByIdx()종료")  
    return result_num

# board 테이블 SELECT (검색)
def selectBoardForSearch(search) :
    if session :
        id = session['login_info'].get('id')
    else :
        id = "guest"
    board_DAO_logger.info(f"{id}: blind_board_DAO.selectBoardForSearch()에 진입")
    result = []
    try :
        con = db_connect()
        cursor = con.cursor(cursor=pymysql.cursors.DictCursor)
        sql_select = 'SELECT * FROM board WHERE title LIKE %s;'
        cursor.execute(sql_select, f'%{search}%')
        
        result = cursor.fetchall()

        cursor.close()
        con.close()

    except Exception as e :
        board_DAO_logger.info(f"{id}: blind_board_DAO.selectBoardForSearch()에서 예외 발생{e}")
    
        board_DAO_logger.info(f"{id}: blind_board_DAO.selectBoardForSearch()종료")
    return result
