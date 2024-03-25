from flask import *
import pymysql
from blindlogging import *

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

# reply 테이블 SELECT (게시글 기준)
def selectReplyByIdx(idx) :
    if session :
        id = session['login_info'].get('id')
    else :
        id = "guest"
    logger_reply.info(f"{id}: blind_reply_DAO.selectReplyByIdx()에 진입")
    result = []
    try :
        con = db_connect()
        cursor = con.cursor(cursor=pymysql.cursors.DictCursor)
        
        sql_select = 'SELECT * FROM reply natural join board WHERE idx = %s'
        cursor.execute(sql_select, idx)
        result = cursor.fetchall()

        cursor.close()
        con.close()

    except Exception as e :
        logger_reply.info(f"{id}: blind_reply_DAO.selectReplyByIdx()에서 예외 발생({e})")
    logger_reply.info(f"{id}: blind_reply_DAO.selectReplyByIdx()종료")        
    return result

# reply 테이블 SELECT (댓글 하나 불러오기)
def selectReplyByIdxrep(idx_rep) :
    if session :
        id = session['login_info'].get('id')
    else :
        id = "guest"
    logger_reply.info(f"{id}: blind_reply_DAO.selectReplyByIdxrep()에 진입")
    result1 = []
    try :
        con = db_connect()
        cursor = con.cursor(cursor=pymysql.cursors.DictCursor)
        
        sql_select = 'SELECT * FROM reply natural join board WHERE idx_rep = %s'
        cursor.execute(sql_select, idx_rep)
        result1 = cursor.fetchone()

        cursor.close()
        con.close()

    except Exception as e :
        logger_reply.info(f"{id}: blind_reply_DAO.selectReplyByIdxrep()에서 예외 발생({e})")
    logger_reply.info(f"{id}: blind_reply_DAO.selectReplyByIdxrep()종료")          
    return result1

# reply 테이블 INSERT
def insertReply(comment, id_rep, name_rep, idx) :
    logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.insertReply()에 진입")

    try :    
        con = db_connect()
        cursor = con.cursor()
        sql_insert = 'INSERT INTO reply (comment, id_rep, name_rep, idx) values (%s, %s, %s, %s)'

        result_num1 = cursor.execute(sql_insert, (comment, id_rep, name_rep, idx))
        
        cursor.close()
        con.close()

    except Exception as e :
        logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.insertReply()에서 예외 발생({e})")
    logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.insertReply()종료")         
    return result_num1

# reply 테이블 UPDATE
def updateReply(comment, id_rep, name_rep, idx_rep) :
    logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.updateReply()에 진입")
    try :       
        con = db_connect()
        cursor = con.cursor()
        sql_update = 'UPDATE reply SET comment = %s, id_rep = %s, name_rep = %s WHERE idx_rep = %s'

        result_num1 = cursor.execute(sql_update, (comment, id_rep, name_rep, idx_rep))
        
        cursor.close()
        con.close()

    except Exception as e :
        logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.updateReply()에서 예외 발생({e})")
    logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.updateReply()종료")         
    return result_num1

# reply 테이블 DELETE
def deleteReplyByIdx(idx_rep) :
    logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.deleteReplyByIdx()에 진입")
    try :      
        con = db_connect()
        cursor = con.cursor()

        sql_delete = 'DELETE FROM reply WHERE idx_rep=%s'
        result_num1 = cursor.execute(sql_delete, idx_rep)

        cursor.close()
        con.close()
        
    except Exception as e :
        logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.deleteReply()에서 예외 발생({e})")
    logger_reply.info(f"{session['login_info'].get('id')}: blind_reply_DAO.deleteReply()종료")   
    return result_num1
