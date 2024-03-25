import pymysql
import re
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

# 로그인한 회원 정보를 Session에 담기위한 SELECT
def selectMemberById(user_id) :

    member_DAO_logger.info(f'member.selectMemberById() 진입')
    result = []
    try :      
        con = db_connect()

        cursor = con.cursor(cursor=pymysql.cursors.DictCursor)
        sql_select = 'SELECT * FROM member WHERE id = %s'
        cursor.execute(sql_select, user_id)
        result = cursor.fetchone()

        cursor.close()
        con.close()
        
    except Exception as e :
        member_DAO_logger.info(f"{id}: blind_member_DAO.selectMemberById()에서 예외 발생({e})")

    member_DAO_logger.info(f'member.selectMemberById() 종료')
    return result

# 회원 1명의 정보 SELECT
def selectMemberByIdx(idx) :

    member_DAO_logger.info(f'member.selectMemberByIdx() 진입')
    result = []
    try :      
        con = db_connect()

        cursor = con.cursor(cursor=pymysql.cursors.DictCursor)
        sql_select = 'SELECT * FROM member WHERE idx = %s'
        cursor.execute(sql_select, idx)
        result = cursor.fetchone()

        cursor.close()
        con.close()
        
    except Exception as e :
        member_DAO_logger.info(f"{id}: blind_member_DAO.selectMemberByIdx()에서 예외 발생({e})")

    member_DAO_logger.info(f'member.selectMemberByIdx() 종료')
    return result

# 회원 정보 UPDATE
def updateMember(user_password, user_name, user_email, user_idx) :
    member_DAO_logger.info(f'member.updateMember() 진입')
    try :       
        con = db_connect()
        cursor = con.cursor()
        sql_update = 'UPDATE member SET password = %s, name = %s, email = %s WHERE idx = %s'

        result_num = cursor.execute(sql_update, (user_password, user_name, user_email, user_idx))
        
        cursor.close()
        con.close()

    except Exception as e :
        member_DAO_logger.info(f"{id}: blind_member_DAO.updateMember()에서 예외 발생({e})")

    member_DAO_logger.info(f'member.updateMember() 종료')              
    return result_num

# 회원 정보 INSERT (회원가입)
def insertMemberInfo(insert_id, insert_password, insert_name, insert_email) : # (유저 정보 받는 함수)
    member_DAO_logger.info(f'member.insertMemberInfo() 진입')
    result = []
    try :    
        con = db_connect()
        cursor = con.cursor()
        sql_insert = 'INSERT INTO member (id, password, name, email) values (%s, %s, %s, %s)'

        result_num = cursor.execute(sql_insert, (insert_id, insert_password, insert_name, insert_email))
        
        cursor.close()
        con.close()

    except Exception as e :
        member_DAO_logger.info(f"{id}: blind_member_DAO.insertMemberInfo()에서 예외 발생({e})")

    member_DAO_logger.info(f'member.insertMemberInfo() 종료')          
    return result_num

# ID 중복 체크를 위한 SELECT
def idDuplicateCheck(insert_id) :
    member_DAO_logger.info(f'member.idDuplicateCheck() 진입')
    try :
        con = db_connect()
        cursor = con.cursor()

        # DB에서 insert_id와 동일한 값 Count
        id_check = 'SELECT id FROM blind.member WHERE id = %s'
        id_result = cursor.execute(id_check, insert_id)

        cursor.close()
        con.close()

        if id_result == 0 :
            member_DAO_logger.info('Available id')
        else:
            member_DAO_logger.warning('Unavailable id')

    except Exception as e :
        member_DAO_logger.info(f"{id}: blind_member_DAO.idDuplicateCheck()에서 예외 발생({e})")

    member_DAO_logger.info(f'member.idDuplicateCheck() 종료')   

    return id_result

# Email 중복 체크를 위한 SELECT
def emailDuplicateCheck(insert_email) :
    member_DAO_logger.info(f'member.emailDuplicateCheck() 진입')
    try :
        con = db_connect()
        cursor = con.cursor()

        # DB에서 insert_email과 동일한 값 Count
        email_check = 'SELECT email FROM blind.member WHERE email = %s'
        email_result = cursor.execute(email_check, insert_email)

        cursor.close()
        con.close()

        if email_result == 0 :
            member_DAO_logger.info('Available email')
        else:
            member_DAO_logger.warning('Unavailable email')

    except Exception as e :
        member_DAO_logger.info(f"{id}: blind_member_DAO.emailDuplicateCheck()에서 예외 발생({e})")

    member_DAO_logger.info(f'member.emailDuplicateCheck() 종료')

    return email_result

# 닉네임 중복 체크를 위한 SELECT
def nameDuplicateCheck(insert_name) :
    member_DAO_logger.info(f'member.nameDuplicateCheck() 진입')
    try :
        con = db_connect()
        cursor = con.cursor()

        # DB에서 insert_id와 동일한 값 Count
        name_check = 'SELECT id FROM blind.member WHERE name = %s'
        name_result = cursor.execute(name_check, insert_name)

        cursor.close()
        con.close()

        if name_result == 0 :
            member_DAO_logger.info('Available name')
        else:
           member_DAO_logger.warning('Unavailable name')

    except Exception as e :
        member_DAO_logger.info(f"{id}: blind_member_DAO.nameDuplicateCheck()에서 예외 발생({e})")

    member_DAO_logger.info(f'member.nameDuplicateCheck() 종료')
    return name_result

# 패스워드 제약 조건 (대문자, 소문자, 숫자, 특수문자 : @$!%*#?&)
def passwordConditionChecker(insert_password):
    member_DAO_logger.info(f'member.passwordConditionChecker() 진입')
    # 비밀번호에 대한 정규표현식 패턴
    pattern = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,20}$"
    if re.match(pattern, insert_password):
        member_DAO_logger.info('Good Password Condition')
        member_DAO_logger.info(f'member.passwordConditionChecker() 종료')
        return True
    else:
        member_DAO_logger.warning('bad Password Condition')
        member_DAO_logger.info(f'member.passwordConditionChecker() 종료')
        return False
    
# member 테이블 DELETE
def deleteMemberByIdx(idx) :
    member_DAO_logger.info(f'member.deleteMemberByIdx() 진입')
    try :      
        con = db_connect()
        cursor = con.cursor()

        sql_delete = 'DELETE FROM member WHERE idx = %s'
        result_num = cursor.execute(sql_delete, idx)

        cursor.close()
        con.close()

    except Exception as e :
        member_DAO_logger.info(f'member.deleteMemberByIdx() 종료')       
    return result_num    
