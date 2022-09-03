<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">
	<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.slim.min.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js"></script>
	<script src="https://ssl.daumcdn.net/dmaps/map_js_init/postcode.v2.js"></script>
	<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
	<style scoped>
		@import url("css/Main.css?ver=1");
	</style>
	<script>
		$(window).on('load', function() {
			$('#main').addClass('loaded');
		});
		
		$(function() {
			$('.nav').css('background-color', '#ffadad');
			var account = JSON.parse(localStorage.getItem('account'));
			var userInfo = JSON.parse(localStorage.getItem('user'));
			if (userInfo==null) {
				$('.small-text').text('환영합니다.')
				$('.animated-text span').text('로그인 부탁드립니다.')
				$('.animated-info').css('display', 'none');
				$('.main_btn_list').css('display', 'none');
				$('.mileage-shop').css('display', 'none');
				$('.mileage-history').css('display', 'none');
				$('#main').css('height', '100vh')
			} else {
				getMileageHistory()
			}
			
			$('#exampleInputKoreaName').val(userInfo.userName);
			$('.small-text-name').text(userInfo.userName);
			$('.item .inner').click(function() {
				var amount = $(this).attr('value');
				swal({
					title: "정말로 구매하시겠습니까?",
					text: "한 번 구매하시면, 청약철회 불가능합니다.",
					icon: "info",
					buttons: true,
				})
				.then((value) => {
					if (value==true) {
						var userInfo = JSON.parse(localStorage.getItem('user'));
						var account = JSON.parse(localStorage.getItem('account'));
						if (account.isMileage=='0') {
							swal({
								title: "마일리지 계좌 문제",
								text: "마일리지 구매에 앞서 마일리지 계좌를 개설하세요.",
								icon: "warning",
								button: true,
							})
						} else {
							$.ajax({
								type: 'post',
								url: '../addMile.do',
								data: {
									'amount': amount,
									'userId': userInfo.userId,
								},
								success: function(res) {
									if(res.message=='yes') {
										console.log(res);
										var accountInfo = new Object();
										$.each(res.account, function(index, item) {
											if (item===null) {
												
											} else {
												accountInfo[index] = item;
											}
										})
										localStorage.setItem('account', JSON.stringify(accountInfo));
										swal({
											title: "Good job!",
											text: "성공적으로 마일리지를 구매했습니다.",
											icon: "success",
											button: "확인!",
										})
										.then((value) => {
											location.href="../Main/Main.jsp";
										})
									}
								},
								error: function(err) {
									console.log(err);
								}
							})
						}
						
					} else {
						
					}
				})
			})
			
			
		})
		
		$(function() {
			if (localStorage.getItem('user')) {
				var userInfo = JSON.parse(localStorage.getItem('user'));
				checkAccount(userInfo.userId);
			}
			
			$(document).keydown(function(event) {
			    if ( event.keyCode == 27 || event.which == 27 ) {
			    	$('.modal').removeClass('show')
			    	$('.modal').css('display', 'none')
			    	$('.modal-backdrop').remove()
			    };
			});
			
			$('#mileage-btn').click(function() {
				swal({
					title: "마일리지 생성",
					text: "마일리지를 정말로 생성하시겠습니까?",
					buttons: ["취소", "생성"],
				})
				.then((value) => {
					var userInfo = JSON.parse(localStorage.getItem('user'))
					if (value==true) {
						$.ajax({
							type: 'post',
							url: '../createMile.do',
							data: {
								'userId': userInfo.userId
							},
							success: function(res) {
								if(res.message=='yes') {
									swal({
									  title: "Good job!",
									  text: "성공적으로 마일리지를 생성했습니다.",
									  icon: "success",
									  button: "확인!",
									})
									.then((value) => {
										location.href="../Main/Main.jsp";
									})
								}
							},
							error: function(err) {
								console.log(err);
							}
						})
					}
				})
			})
			
			$('.create-account').click(function() {
				var userInfo = JSON.parse(localStorage.getItem('user'))
				var phone = $('#exampleInputPhone').val().slice(0,3) + $('#exampleInputPhone').val().slice(4,8) + $('#exampleInputPhone').val().slice(9, 13)
				accData = {
					'userId': userInfo.userId,
					'accPassword': passNum,
					'userNameEng': $('#exampleInputEnglishName').val(),
					'address': $('#exampleInputAddress').val(),
					'phone': phone
				};
				$.ajax({
					type: 'post',
					url: '../createAcc.do',
					data: accData,
					success: function(res) {
						if(res.message=="yes") {
							swal({
								title: "계좌 생성",
								text: "계좌를 성공적으로 생성했습니다.",
								icons: "success",
								buttons: "확인",
							})
							.then((value) => {
								if(value==true) {
									location.reload();
								}
								
							})
						}
					},
					error: function(err) {
						console.log(err)
					}
				})
			})
			
		})
		
		function checkAccount(userId) {
			$.ajax({
				type: 'post',
				url: '../checkUserAcc.do',
				data: {
					'userId': userId
				},
				// 응답 부분
				success: function(res) {
					if(res.message== 'no') {
						swal({
							title: "계좌 조회",
							text: "계좌가 존재하지 않습니다. 생성하시겠습니까?",
							buttons: ["취소", "생성"],
						})
						.then((value) => {
							if (value==true) {
								$('.modal').addClass('show');
								$('.modal').css('display', 'block');
								$('body').append('<div class="modal-backdrop fade show"></div>');
							}
						})
					} else {
						$.ajax({
							type: 'post',
							url: '../getAccount.do',
							data: {
								'userId': userId
							},
							// 응답 부분
							success: function(res) {
								if(res.message == 'yes') {
									var accountInfo = new Object();
									$.each(res.account, function(index, item) {
										if (item===null) {
											
										} else {
											accountInfo[index] = item;
										}
									})
									localStorage.setItem('account', JSON.stringify(accountInfo));
									var accAmount = accountInfo.accAmount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
									$('.account-amount').text(accAmount);
									 
									if (res.account.isMileage=="0") {
										$('#mileage-btn').css('display', 'block');
										$('#account-btn').css('width', '40%');
									} else {
										var mileage = accountInfo.mileage.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
										$('.mileage-amount').text(mileage);
										$('#mileage-btn').css('display', 'none');
										$('#account-btn').css('width', '90%');
									}
									if (accountInfo.isMileage==0) {
										$('.mileage-history').css('display', 'none')
									} else {
										
									}
								}
							},
							error: function(err) {
								console.log(err);
							}
						})
					
					}
				},
				error: function(err) {
					console.log(err);
				}
			})
		};
		
		
		function mobile_keyup(obj){
		    let mobile_len = obj.value.length;
		    if(event.keyCode==8){
		        obj.value=obj.value.slice(0,mobile_len); 
		        return 0; 
		    }else if (mobile_len==3 || mobile_len==8){
		        obj.value += '-';
		    }
		}
		
		function openHomeSearch(){
			new daum.Postcode({
				oncomplete:function(data){
					$('[name=postno]').val(data.zonecode);
					$('[name=addr]').val(data.address);
					$('[name=detAddr]').val(data.buildingName);
					$('#exampleInputAddress').val(data.roadAddress);
				}
			}).open({
		        left: window.screenLeft/2,
		        right: window.screenTop/2,
		        popupKey: 'popup1',
		        autoClose: true,
		      });
		}
		
		function getMileageHistory() {
			var userInfo = JSON.parse(localStorage.getItem('user'))
			$.ajax({
				type: 'post',
				url: '../getMileHistory.do',
				data: {
					'userId': userInfo.userId
				},
				success: function(res) {
					mileageHistory = res.mileageHistory
					var cnt = 1;
					$.each(mileageHistory, function(index, item) {
						$('.fl-table tbody').append(
							'<tr>' +
					            '<td>'+cnt+'</td>' +
					            '<td style=line-height:1.5;>'+item.createTime+'</td>' +
					            '<td>'+item.mileageAmount+' MP</td>' +
					            '<td>'+item.mileageContent+'</td>' +
					        '</tr>'
						);
						cnt += 1
					})
					/*
					<tr>
			            <td>Content 1</td>
			            <td>Content 1</td>
			            <td>Content 1</td>
			            <td>Content 1</td>
			        </tr>
			        */
				},
				error: function(err) {
					console.log(err)
				}
			})
		}
		
		var passNum = "";
		var passIdx = 0;
		
		$(function() {
			$('.pass-num').click(function() {
				var txt = $(this).text();
				if (txt=='확인') {
					alert('비밀번호 지정되었습니다.');
				} else if (txt=='초기화') {
					$('.pass-box').eq(0).text("");
					$('.pass-box').eq(1).text("");
					$('.pass-box').eq(2).text("");
					$('.pass-box').eq(3).text("");
					passIdx = 0;
					passNum = "";
				} else {
					if (passIdx == 0) {
						$('.pass-box').eq(0).text(txt);
					} else if (passIdx == 1) {
						$('.pass-box').eq(1).text(txt);
					} else if (passIdx == 2) {
						$('.pass-box').eq(2).text("*");
					} else if (passIdx == 3) {
						$('.pass-box').eq(3).text("*");
					}
					passNum += txt;
					passIdx += 1;
				}
				
			})
		})
		
	</script>
</head>
<body>
	<div id="main">
		<div id="loader-wrapper">            
			<div id="loader"></div>
			<div class="loader-section section-left"></div>
			<div class="loader-section section-right"></div>
		</div>
	    <%@ include file="../Common/Nav.jsp" %>
	    
	    <div class="container pb-4" style="margin-top: 5rem;">
	    	<div class="row">
	            <div class="col-7 d-flex align-items-center">
	                <div class="about-text">
	                    <h5 class="small-text" style="font-family: 'Happiness-Sans-Title';">환영합니다.&nbsp;<span class="small-text-name"></span>&nbsp;고객님!!</h5>
	                    <h1 class="animated animated-text">
	                        <span class="mr-2" style="font-family: 'Happiness-Sans-Title';">현재 금액은</span>
                            <div class="animated-info">
                                <span class="animated-item">연동 계좌 : <span class="account-amount">0</span>원</span>
                                <span class="animated-item">마일리지 : <span class="mileage-amount">0</span>원</span>
                            </div>
	                    </h1>
						<br>
	                    <p style="font-family: 'Happiness-Sans-Title';">기부 낫 테이크기부 낫 테이크기부 낫 테이크기부 낫 테이크기부 낫 테이크</p>
	                    <p style="font-family: 'Happiness-Sans-Title';">기부 낫 테이크기부 낫 테이크기부 낫 테이크기부 낫 테이크기부 낫 테이크기부 낫 테이크기부 낫 테이크기부 낫 테이크</p>
	                    <br><br>
	                    <div class="main_btn_list">
							<button class="btn-slide-line" id="account-btn" style="width: 40%; margin-right: 2rem;" data-toggle="modal" data-target="#exampleModal">계좌 관리</button>
							<button class="btn-slide-line" id="mileage-btn" style="width: 40%;">마일리지 생성</button>
							<!-- Modal -->
							<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
							  <div class="modal-dialog" role="document">
							    <div class="modal-content" style="border-radius: 4rem; width: 190%; left: -10%;">
							      <div class="modal-body" style="padding: 0px;">
							        <div class="column" id="main-modal">
							          <h1>계좌 생성</h1>
							          <div class="modal-form">
							            <div class="form-group">
							              <label for="exampleInputKoreaName">한글 이름</label>
							              <input type="name" class="form-control" id="exampleInputKoreaName" disabled>
							            </div>
							            <div class="form-group">
							              <label for="exampleInputEnglishName">영어 이름</label>
							              <input type="name" class="form-control" id="exampleInputEnglishName" placeholder="Name">
							            </div>
							            <div class="form-group">
							              <label for="exampleInputPhone">전화번호 </label>
							              <input type="tel" onkeyup="mobile_keyup(this)" maxlength='13' class="form-control" id="exampleInputPhone" placeholder="010-0000-0000">
							            </div>
							            <div class="form-group">
							              <label for="exampleInputAddress">주소</label>
							              <input type="text" onclick="openHomeSearch()" class="form-control" id="exampleInputAddress" placeholder="주소를 입력하세요">
							            </div>
							            <button type="submit" class="create-account">계좌 생성하기</button>
							          </div>
							        </div>
							        <div>
							          <?xml version="1.0" encoding="UTF-8"?>
							          <svg width="67px" height="578px" viewBox="0 0 67 578" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
							              <!-- Generator: Sketch 53.2 (72643) - https://sketchapp.com -->
							              <title>Path</title>
							              <desc>Created with Sketch.</desc>
							              <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
							                  <path d="M11.3847656,-5.68434189e-14 C-7.44726562,36.7213542 5.14322917,126.757812 49.15625,270.109375 C70.9827986,341.199016 54.8877465,443.829224 0.87109375,578 L67,578 L67,-5.68434189e-14 L11.3847656,-5.68434189e-14 Z" id="Path" fill="#ffcaca"></path>
							              </g>
							          </svg>
							        </div>
							        <div class="column" id="secondary">
							          <div class="sec-content">
							          	<h1>계좌 비밀번호</h1>
							          	<div class="d-flex justify-content-center">
							          		<div class="pass-box"></div>
							          		<div class="pass-box"></div>
							          		<div class="pass-box"></div>
							          		<div class="pass-box"></div>
							          	</div>
							          	<div class="row justify-content-center" style="margin-top: 2rem; padding: 2rem;">
							          		<c:forEach var="i" begin="0" end="9">
							          			<div class="col-3 pass-num">${i}</div>
							          		</c:forEach>
							          		<div class="col-3 pass-num">초기화</div>
							          		<div class="col-3 pass-num">확인</div>
							          	</div>
							          </div>
							        </div>
							      </div>
							    </div>
							  </div>
							</div>
	                    </div>
	                </div>
	            </div>
				<br><br>
	            <div class="col-5">
	                <div class="about-image svg">
	                    <img src="img/undraw_software_engineer_lvl5.svg" class="img-fluid" alt="svg image">
	                </div>
	            </div>
	        </div>
	    </div>
	    
	    <div class="container mileage-shop" style="padding: 2rem;">
       		<h3 class="mileage-h3" style="margin-bottom: 3rem;">마일리지 구매</h3>
       		<div class="d-flex justify-content-start">
       			<ul class="items">
				    <li class="item">
				      <div class="inner" value="1">
				        <h4 class="name">10,000MP</h4>
				        <p class="descr"></p>
				      </div>
				    </li>
				    <li class="item">
				      <div class="inner" value="2">
				        <h4 class="name">30,000MP</h4>
				        <p class="escr">+3,000MP</p>
				      </div>
				    </li>
				    <li class="item">
				      <div class="inner" value="3">
				        <h4 class="name">50,000MP</h4>
				        <p class="descr">+5,000MP</p>
				      </div>
				    </li>
				    <li class="item">
				      <div class="inner" value="4">
				        <h4 class="name">100,000MP</h4>
				        <p class="descr">+10,000MP</p>
				      </div>
				    </li>
				  </ul>
       		</div>
       		
	    </div>
	    <div class="container mileage-history" style="padding: 2rem;">
	    	<h3 class="mileage-h3" style="margin-bottom: 3rem;">마일리지 구매 내역</h3>
	    	<div class="d-flex justify-content-center">
		    	<table class="fl-table">
			        <thead>
				        <tr>
				            <th>번&nbsp;&nbsp;호</th>
				            <th>날&nbsp;&nbsp;짜</th>
				            <th>금&nbsp;&nbsp;액</th>
				            <th>내&nbsp;&nbsp;역</th>
				        </tr>
			        </thead>
			        <tbody>
			        
			        </tbody>
			    </table>
	    	</div>
	    </div>
	    <div style="padding: 2.5rem;"></div>
	</div>
</body>
</html>