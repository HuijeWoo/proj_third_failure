const input = document.querySelector(".finder__input");
const finder = document.querySelector(".finder");
const form = document.querySelector("form");

input.addEventListener("focus", () => {
  finder.classList.add("active");
});

input.addEventListener("blur", () => {
  if (input.value.length === 0) {
    finder.classList.remove("active");
  }
});

form.addEventListener("submit", (ev) => {
  ev.preventDefault();
  finder.classList.add("processing");
  finder.classList.remove("active");
  input.disabled = true;
  setTimeout(() => {
    finder.classList.remove("processing");
    input.disabled = false;
    if (input.value.length > 0) {
      finder.classList.add("active");
    }
  }, 1000);
});

input.addEventListener('keypress', function (e) {
  if (e.key === 'Enter') {
    e.preventDefault();
    form.submit();
  }
});

// ID 영문자/숫자만 허용
function checkReg(event) {
  const regExp = /[^0-9a-zA-Z.@]/g; // 숫자와 영문자만 허용
  const del = event.target;
  if (regExp.test(del.value)) {
    del.value = del.value.replace(regExp, '');
  }
};

function checkRegister() {

  let check_id = $("#check_id").val();
  let check_pw = $("#check_pw").val();
  let check_name = $("#check_name").val();
  let check_email = $("#check_email").val();

  if(check_id == 'true' && check_pw == 'true' &&
     check_name == 'true' && check_email == 'true'){
      return true
  } else {
    return false
  }
}