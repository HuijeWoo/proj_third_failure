from flask import *
import blind_board_DAO
import blind_reply_DAO
from blindlogging import *

bp = Blueprint("board", __name__, url_prefix="/board")

# 글쓰기
@bp.route("/write", methods=['POST', 'GET'])
def write() :
    if request.method == 'GET' :
        return render_template('write.html')
    
    elif request.method == 'POST' :

        # id와 name은 session에서 가져옴
        title = request.form['title']
        contents = request.form['contents']
        blind_board_DAO.insertBoard(title, contents, '익명', '익명')

        return redirect(url_for('index')) 

# 글 상세보기
@bp.route('/detail/<int:num>', methods=['GET'])
def detail(num) :
    # 세션 정보 가져가기
    if 'login_info' in session :
        session_user = session['login_info']
        logger_board.info(f"{session_user['id']}: board.detail({num})에 진입")
        try:   
            # 해당 글의 idx로 SELECT
            select_result = blind_board_DAO.selectBoardByIdx(num)
            # 댓글 추가 내용
            select_result1 = blind_reply_DAO.selectReplyByIdx(num)
            logger_board.info(f"{session_user['id']}: board.detail({num})종료")
        except Exception as e:
            logger_board.error(f"{session_user['id']}: board.detail에서 예외 발생({e})")

    # 세션 정보가 없는 guest
    else :
        try:
            logger_board.info(f"guest: board.detail({num})에 진입")
            select_result = blind_board_DAO.selectBoardByIdx(num)
            # 댓글 추가 내용
            select_result1 = blind_reply_DAO.selectReplyByIdx(num)
            logger_board.info(f"guest: board.detail({num})종료")
        except Exception as e:
            logger_board.error(f"guest: board.detail에서 예외 발생({e})")

    if 'login_info' in session :
        return render_template('detail.html', select_result = select_result, session_user = session_user, select_result1=select_result1, idx=num)
    else :
        return render_template('detail.html', select_result = select_result, select_result1=select_result1)
    

# 글 수정하기
@bp.route('/edit/<int:num>', methods=['POST', 'GET'])
def edit(num) :
    # 세션 정보 가져가기
    session_user = session['login_info']        
    try:
        if request.method == 'GET' :
            logger_board.info(f"{session_user['id']}: GET으로 board.edit({num})에 진입")
            # 해당 글의 idx로 SELECT
            select_result = blind_board_DAO.selectBoardByIdx(num)       
            # alchemy_board_repository.updateBoard(idx, title, contents, session_user['id'], session_user['name']) 
            return render_template('edit.html', select_result = select_result, session_user = session_user)
        elif request.method == 'POST' :
            logger_board.info(f"{session_user['id']}: POST로 board.edit{num}에 진입")
            # id와 name은 session에서 가져옴
            idx = request.form['idx']
            title = request.form['title']
            contents = request.form['contents']
            blind_board_DAO.updateBoard(idx, title, contents, session_user['id'], session_user['name'])
            # alchemy_board_repository.updateBoard(idx, title, contents, session_user['id'], session_user['name'])
            logger_board.info(f"{session_user['id']}: board.edit({num})종료")
    except Exception as e:
        logger_board.error(f"{session_user['id']}: board.edit({num})에서 예외 발생({e})")
    
    return redirect(url_for('index'))


# 글 삭제하기
@bp.route('/delete/<int:num>', methods=['GET'])
def delete(num) :
    try:
        logger_board.info(f"{session['login_info'].get('id')}: board.delete({num})에 진입함")
        blind_board_DAO.deleteBoardByIdx(num)
        # alchemy_board_repository.deleteBoardByIdx(num)
        logger_board.info(f"{session['login_info'].get('id')}: board.delete({num})종료")
    except Exception as e:
        logger_board.error(f"{session['login_info'].get('id')}: board.delete에서 예외 발생({e})")

    return redirect(url_for('index'))


# 검색어 수집 및 검색 로직에 전달
@bp.route('/search', methods=['POST'])
def search():
    search_query = request.form['search']
    
    return redirect(url_for('board.search_results', query = search_query))

# 검색
@bp.route('/search_results/<query>')
def search_results(query):
    try:
        if 'login_info' in session :
            session_user = session['login_info']
            logger_board.info(f"{session_user['id']}: board.search_results({query})진입")
            
            search_result = blind_board_DAO.selectBoardForSearch(query)
            # search_result = alchemy_board_repository.selectBoardForSearch(query)
            return render_template('search.html', session_user = session_user, search_result = search_result)
        else :
            id = "guest"
            logger_board.info(f"{id}: board.search_results({query})진입")
            search_result = blind_board_DAO.selectBoardForSearch(query)
            # search_result = alchemy_board_repository.selectBoardForSearch(query)

    except Exception as e:
        logger_board.error(f"{id}: board.search_results({query})에서 예외 발생({e})")

    logger_board.info(f"{id}: board.search_results({query})종료")
    return render_template('search.html', search_result = search_result)

# 댓글 추가
@bp.route('/detail/<int:num>', methods=['POST'])
def replyInsert(num) :
    if 'login_info' in session :
        try:
            # id와 name은 session에서 가져옴
            session_user = session['login_info']
            # 해당 글의 idx는 num과 동일하므로 num으로 SELECT
            logger_board.info(f"{session_user['id']}: board.replyInsert({num})에 진입")
            # 추가 내용
            comment = request.form['comment']
            blind_reply_DAO.insertReply(comment, session_user['id'], session_user['name'], num)
            # blind_reply_DAO.insertReply(comment, session_user['id'], session_user['name'], num)
            # post 값 반환 없이 원래의 게시판으로 이동
            logger_board.info(f"{session_user['id']}: board.replyInsert({num})종료")

        except Exception as e:
            logger_board.error(f"{session_user['id']}: board.relyInsert({num})에서 예외 발생({e})")    

        return "<script>location.href='"+str(num)+"'</script>"


# 댓글 수정하기
@bp.route('/editreply/<int:num>', methods=['POST','GET'])
def editreply(num) :
    # id와 name은 session에서 가져옴
    session_user = session['login_info']
    try:
        if request.method == 'GET' :
            logger_board.info(f"{session_user['id']}: GET으로 board.editreply({num})에 진입")
            # 해당 글의 idx는 num과 동일하므로 num으로 SELECT
            # idx_rep 은 select_result1에서 가져옴
            select_result1 = blind_reply_DAO.selectReplyByIdxrep(num)
            
            return render_template('editreply.html', select_result1=select_result1, session_user=session_user) 
        
        if request.method == 'POST' :
            logger_board.info(f"{session_user['id']}: POST로 board.editreply({num})에 진입")
            # 해당 글의 idx는 num과 동일하므로 num으로 SELECT
            # idx_rep 은 select_result1에서 가져옴
            select_result1 = blind_reply_DAO.selectReplyByIdxrep(num)
            comment = request.form['comment']
            
            blind_reply_DAO.updateReply(comment, session_user['id'], session_user['name'], num)
            num = select_result1['idx']
    except Exception as e:
        logger_board.error(f"{session_user['id']}: board.editreply({num})에서 예외 발생({e})")

    return redirect(url_for(('board.detail'),num=num))

# 댓글 삭제
@bp.route('/deletereply/<int:num>', methods=['GET'])
def deletereply(num) :
    try:
        logger_board.info(f"{session['login_info'].get('id')}: board.deletereply({num})에 진입")
        res = blind_reply_DAO.selectReplyByIdxrep(num)
        blind_reply_DAO.deleteReplyByIdx(num)
        num = res['idx']
        logger_board.info(f"{session['login_info'].get('id')}: board.deletereply({num})종료")

    except Exception as e:
        logger_board.error(f"{session['login_info'].get('id')}: board.editreply({num})에서 예외 발생({e})")
        
    return redirect(url_for('board.detail', num = num))
