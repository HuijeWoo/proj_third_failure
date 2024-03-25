from flask import *
import blind_member_DAO
from blindlogging import *

bp = Blueprint("member", __name__, url_prefix="/member")

# ID 중복체크
@bp.route('/idDuplicateCheck', methods=['POST'])
def idDuplicateCheck() :
    member_logger.info('member.idDuplicateCheck() 진입')
    user_id = request.get_json()
    # ID & Email 중복 검사 및 결과
    id_result = blind_member_DAO.idDuplicateCheck(user_id)
    # id_result = alchemy_member_repository.idDuplicateCheck(user_id)
    if id_result :
        result = {'status' : 'success', 'result' : id_result, 'message' : '이미 사용중인 ID입니다'}
    else :
        result = {'status' : 'fail', 'result' : id_result, 'message' : '사용할 수 있는 ID입니다.'}
    member_logger.info('member.idDuplicateCheck() 종료')    
    return jsonify(result)

# 비밀번호 상태 체크
@bp.route('/passwordConditionCheck', methods=['POST'])
def passwordConditionCheck() :
    member_logger.info('member.passwordConditionCheck() 진입')
    user_password = request.get_json()
    # ID & Email 중복 검사 및 결과
    password_result = blind_member_DAO.passwordConditionChecker(user_password)
    if password_result == False :
        result = {'status' : 'success', 'result' : password_result, 'message' : '사용할 수 없는 PASSWORD입니다'}
    else :
        result = {'status' : 'fail', 'result' : password_result, 'message' : '사용할 수 있는 PASSWORD입니다.'}
    member_logger.info('member.passwordConditionCheck() 종료')    
    return jsonify(result)

# email 중복 체크
@bp.route('/emailDuplicateCheck', methods=['POST'])
def emailDuplicateCheck() :
    member_logger.info('member.emailDuplicateCheck() 진입')
    user_email = request.get_json()
    email_result = blind_member_DAO.emailDuplicateCheck(user_email)
    if email_result :
        result = {'status' : 'success', 'result' : email_result, 'message' : '사용할 수 없는 E-mail입니다'}
    else :
        result = {'status' : 'fail', 'result' : email_result, 'message' : '사용할 수 있는 E-mail입니다.'}
    member_logger.info('member.emailDuplicateCheck() 종료')    
    return jsonify(result)

# 닉네임 중복 체크
@bp.route('/nameDuplicateCheck', methods=['POST'])
def nameDuplicateCheck() :
    member_logger.info('member.nameDuplicateCheck() 진입')
    user_name = request.get_json()
    name_result = blind_member_DAO.nameDuplicateCheck(user_name)
    if name_result :
        result = {'status' : 'success', 'result' : name_result, 'message' : '이미 사용중인 닉네임입니다'}
    else :
        result = {'status' : 'fail', 'result' : name_result, 'message' : '사용할 수 있는 닉네임입니다.'}
    member_logger.info('member.nameDuplicateCheck() 종료')    
    return jsonify(result)

# 회원가입
@bp.route('/register', methods=['POST', 'GET'])
def register() :
    if request.method == 'GET' :
        member_logger.info('member.register() GET 진입')
        member_logger.info('enter the sign up page')
        return render_template('member/register.html')
    elif request.method == 'POST' :
        member_logger.info('member.register() POST 진입')
        # 입력 받은 데이터 변수 설정
        insert_id = request.form['user_id']
        insert_password = request.form['user_password']
        insert_name = request.form['user_name']
        insert_email = request.form['user_email']

        # alchemy_member_repository.insertMemberInfo(insert_id, insert_password, insert_name, insert_email)
        blind_member_DAO.insertMemberInfo(insert_id, insert_password, insert_name, insert_email)
        member_logger.info(f'Registration Complete! Welcome {insert_id}')
        member_logger.info('member.register() 종료')
        return redirect(url_for('index'))

    else :
        member_logger.critical('비정상 접근')
        member_logger.info('member.register() 종료')
        return redirect(url_for('index'))
    
# 로그인
@bp.route('/login', methods=['POST', 'GET'])
def login() :
    if request.method == 'GET' :
        member_logger.info('member.login() GET 진입')
        member_logger.info('enter the login page')
        return render_template('member/login.html')
    elif request.method == 'POST' :
        member_logger.info('member.login() POST 진입')
        # Form에서 입력한 id
        user_id = request.form['user_id']
        # Form에서 입력한 password
        user_password = request.form['user_password']
        # Form에서 입력한 id를 기반으로 DB 검색
        user_result = blind_member_DAO.selectMemberById(user_id)
        # user_result = alchemy_member_repository.selectMemberById(user_id)
        
        if user_result is not None :
            # Form에서 입력한 정보와 DB 정보 비교 후 일치하면 유저의 모든 정보를 Session에 저장
            if(user_id == user_result['id'] and user_password == user_result['password']) :
                session['login_info'] = user_result
                id = session['login_info'].get('id')
                member_logger.info(f'login Success! Welcome, {id}')
                member_logger.info('member.login() 종료')
                return redirect(url_for('index'))
            else :
                member_logger.warning('login pw Fail')
                member_logger.info('member.login() 종료')
                return render_template('member/login_fail.html')
        else :
            member_logger.warning('login id Fail')
            member_logger.info('member.login() 종료')
            return render_template('member/login_fail.html')
    else :
        member_logger.critical('비정상 접근')
        member_logger.info('member.login() 종료')
        return render_template('index.html')
    
# 로그아웃
@bp.route('/logout')
def logout() :
    id = session['login_info'].get('id')
    member_logger.info('member.logout() 진입')

    if 'login_info' in session :
        session.pop('login_info', None)
        member_logger.info(f'{id}logout Success')
        member_logger.info('member.logout() 종료')
        return redirect(url_for('index'))
    else :
        member_logger.info('Already logout')
        member_logger.info('member.logout() 종료')
        return '<h2>User already logged out <a href="/index">Click here</a></h2>'
    
# 회원 MyPage
@bp.route('/mypage', methods=['GET', 'POST'])
def myPage() :
    member_logger.info('myPage() 진입')
    id = session['login_info'].get('id')
    
    session_user = session['login_info']
    member_logger.info(f'User {id} myPage 진입')
    member_logger.info('myPage() 종료')
    return render_template('member/mypage.html', session_user = session_user)

# 회원 MyPage 수정화면
@bp.route('/mypageEdit/<int:num>', methods=['GET', 'POST'])
def myPageEdit(num) :

    id = session['login_info'].get('id')
    if request.method == 'GET' :
        
        member_logger.info(f'User {id} member.myPageEdit() GET 진입')

        # 세션 정보 가져가기
        session_user = session['login_info']        
        # 해당 글의 idx로 SELECT
        select_result = blind_member_DAO.selectMemberByIdx(num)
        # select_result = alchemy_member_repository.selectMemberByIdx(num)
        return render_template('member/mypageEdit.html', select_result = select_result, session_user = session_user) 
    elif request.method == 'POST' :
        member_logger.info(f'User {id} member.myPageEdit() POST 진입')
        user_idx = request.form['user_idx']
        user_id = request.form['user_id']
        user_password = request.form['user_password']
        user_name = request.form['user_name']
        user_email = request.form['user_email']
        blind_member_DAO.updateMember(user_password, user_name, user_email, user_idx)
        # select_result = alchemy_member_repository.selectMemberByIdx(num)
        member_logger.info(f'User {id} update Complete')        
        # Session 갱신 후 index redirect
        session['login_info'] = blind_member_DAO.selectMemberById(user_id)
        member_logger.debug('session Update')
        member_logger.info('member.myPageEdit() 종료')
        return redirect(url_for('index'))
    

#회원 탈퇴
@bp.route('/signout', methods=['POST'])
def signout() :
    id = session['login_info'].get('id')
    member_logger.info('member.signout() 진입')

    session_user_idx = session['login_info']['idx']
    blind_member_DAO.deleteMemberByIdx(session_user_idx)
    # alchemy_member_repository.deleteMemberByIdx(session_user_idx)
    member_logger.warning(f'User {id} Delete Success')
    member_logger.info('member.signout() 종료')
    return redirect(url_for('member.logout'))

