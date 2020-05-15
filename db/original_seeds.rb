# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# USERS SETUP #
admin = User.create(:username => 'cody', :email => 'codybaldwin@gmail.com', :approved => true, :admin => true, role: 2, :password => 'Am0E6EfdK*6uP^!', :password_confirmation => 'Am0E6EfdK*6uP^!')
boss = User.create(:username => 'funabiki', :email => 'funabiki@protonmail.com', :approved => true, :admin => true, role: 2, :password => 'oyster123', :password_confirmation => 'oysteroyster')
yano = User.create(:username => 'office', :email => 'info@funabiki.info', :approved => true, :admin => false, role: 1, :password => 'oysteroyster', :password_confirmation => 'oysteroyster')
user = User.create(:username => 'user', :email => 'funabikioyster@gmail.com', :approved => true, :admin => false, role: 1, :password => 'oyster', :password_confirmation => 'oysteroyster')

# CATEGORIES SETUP #
	intro = Category.create(name: '紹介')
		company_info = Category.create(name: '会社概要', parent: intro)
		philosophy = Category.create(name: '会社理念', parent: intro)
		products = Category.create(name: '商品', parent: intro)
		supply = Category.create(name: '原料', parent: intro)

	gmp = Category.create(name: '工場・加工')
		gmps = Category.create(name: '適正製造基準(GMP)', parent: gmp)
		equipment = Category.create(name: '機械', parent: gmp)
		maintain = Category.create(name: '整備', parent: gmp)
		training = Category.create(name: 'トレーニング', parent: gmp)

	scp = Category.create(name: '衛生管理手順(SCPs)')
		water = Category.create(name: '水の安全性', parent: scp)
			seapump = Category.create(name: '海水パンプ', parent: water)
			sandfilter = Category.create(name: 'サンドフィルター(ろ過 砂)', parent: water)
			rockfilter = Category.create(name: 'ろ過 石', parent: water)
			ultraviolet = Category.create(name: '紫外線殺菌プール(冷却)', parent: water)
			frptank = Category.create(name: 'FRPタンク', parent: water)
			chilltank = Category.create(name: 'ステンレスタンク(冷却)', parent: water)
			citywater = Category.create(name: '水道水', parent: water)
			groundwater = Category.create(name: '地下水', parent: water)
			icemaking = Category.create(name: '粒氷製造機', parent: water)
		surfaces = Category.create(name: '食品に接触する表面の状態および清潔さ', parent: scp)
			machines = Category.create(name: '機械の表面', parent: surfaces)
			tables = Category.create(name: 'テーブルなだの表面', parent: surfaces)
			buckets = Category.create(name: 'テンタル(牡蠣の樽)', parent: surfaces)
			tools = Category.create(name: '網やスコップなどの道具', parent: surfaces)
		crosscont = Category.create(name: '交差汚染の防止', parent: scp)
		facilities = Category.create(name: '手指洗浄、手指消毒、トイレ設備の維持管理', parent: scp)
		adulterants = Category.create(name: '食用不敵にする物質からの保護', parent: scp)
		toxins = Category.create(name: '有害化合物の表示、保管、使用', parent: scp)
		health = Category.create(name: '従業員の健康状態', parent: scp)
		pests = Category.create(name: '有害小動物の駆除', parent: scp)


	haccp = Category.create(name: 'HACCP')
		team = Category.create(name: 'HACCP チームの編成', parent: haccp)
		ccpproduct = Category.create(name: '製品説明書', parent: haccp)
		flowchart = Category.create(name: '製造工程図', parent: haccp)
		hazards = Category.create(name: '危害要因の分析', parent: haccp)
		limits = Category.create(name: '重要管理点(CCP)', parent: haccp)
		monitor = Category.create(name: '管理基準(CL)の設定・モニタリング方法', parent: haccp)
		corrective = Category.create(name: '不具合があった時には「改善措置」', parent: haccp)
		verif = Category.create(name: '定期的に見直す「検証」', parent: haccp)
		records = Category.create(name: '記録の文書化と保管', parent: haccp)

	docs = Category.create(name: '記録・書類')
		training = Category.create(name: 'トレーニング', parent: docs)
		ssop = Category.create(name: 'SSOPモニタリング', parent: docs)


# MATERIALS #
	# TAPE #
		white_tape = Material.create(namae: '船曳青色　クラフトテープ (50m)', zairyou:'テープ', cost: 185.0, divisor: 50, history: {})
		brown_tape = Material.create(namae: '茶色　クラフトテープ (50m)', zairyou:'テープ', cost: 81.0, divisor: 50, history: {})
		sky_tape = Material.create(namae: '水色　クラフトテープ (50m)', zairyou:'テープ', cost: 158.0, divisor: 50, history: {})
		navy_tape = Material.create(namae: '紺色　クラフトテープ (50m)', zairyou:'テープ', cost: 158.0, divisor: 50, history: {})
		orange_tape = Material.create(namae: 'オレンジ色　クラフトテープ (50m)', zairyou:'テープ', cost: 158.0, divisor: 50, history: {})
		brown_tape = Material.create(namae: '赤色　クラフトテープ (50m)', zairyou:'テープ', cost: 158.0, divisor: 50, history: {})
		orange_tape = Material.create(namae: 'オレンジ色　クラフトテープ (50m)', zairyou:'テープ', cost: 158.0, divisor: 50, history: {})
		yellow_tape = Material.create(namae: '黄色　クラフトテープ (50m)', zairyou:'テープ', cost: 158.0, divisor: 50, history: {})
		pink_tape = Material.create(namae: 'ピンク色　クラフトテープ (50m)', zairyou:'テープ', cost: 158.0, divisor: 50, history: {})
		clear_tape = Material.create(namae: 'クリア　クラフトテープ (100m)', zairyou:'テープ', cost: 116.0, divisor: 100, history: {})
	# BOXES & LIDS #
		# Small boxes
		ft1_box = Material.create(namae: 'FT-1', zairyou:'箱', cost: 88.0, divisor: 1, history: {})
		p3_box = Material.create(namae: 'P-3', zairyou:'箱', cost: 76.0, divisor: 1, history: {})
		p3samurai_box = Material.create(namae: 'P-3(サムライ)', zairyou:'箱', cost: 91.0, divisor: 1, history: {})
		p3p4samurai_lid = Material.create(namae: 'P-3/4フタ(サムライ) フタ', zairyou:'フタ', cost: 40.0, divisor: 1, history: {})
		p3p4_lid = Material.create(namae: 'P-3/4 フタ', zairyou:'フタ', cost: 30.0, divisor: 1, history: {})
		p4_box = Material.create(namae: 'P-4', zairyou:'箱', cost: 76.0, divisor: 1, history: {})
		p4samurai_box = Material.create(namae: 'P-4(サムライ)', zairyou:'箱', cost: 91.0, divisor: 1, history: {})
		# White open anago box
		t5_box = Material.create(namae: 'T-5', zairyou:'箱', cost: 42.0, divisor: 1, history: {})
		# 1K 10-pack box
		yt100_box = Material.create(namae: 'YT-100（穴あき）', zairyou:'箱', cost: 197.0, divisor: 1, history: {})
		# 300G and "Big" Box
		yt101_lid = Material.create(namae: 'YT-101 フタ', zairyou:'フタ', cost: 85.0, divisor: 1, history: {})
		yt101samurai_lid = Material.create(namae: 'YT-101(サムライ) フタ', zairyou:'フタ', cost: 95.0, divisor: 1, history: {})
		yt101gokujyoblue_lid = Material.create(namae: 'YT-101(極上青) フタ', zairyou:'フタ', cost: 95.0, divisor: 1, history: {})
		yt101_box = Material.create(namae: 'YT-101', zairyou:'箱', cost: 184.0, divisor: 1, history: {})
		# New big box
		yt112_lid = Material.create(namae: 'YT-112 フタ', zairyou:'フタ', cost: 75.0, divisor: 1, history: {})
		yt112_box = Material.create(namae: 'YT-112', zairyou:'箱', cost: 135.0, divisor: 1, history: {})
		# Regular pack "hancotsu" box
		yt115_lid = Material.create(namae: 'YT-115 フタ', zairyou:'フタ', cost: 49.2, divisor: 1, history: {})
		yt115_box = Material.create(namae: 'YT-115', zairyou:'箱', cost: 91.8, divisor: 1, history: {})
		# "Kotubako"/ the cube box
		yt20_box_lid = Material.create(namae: 'YT-20 (フタ含む)', zairyou:'箱', cost: 191.0, divisor: 1, history: {})
		# CyuBukuro 20-tube box
		yt202_lid = Material.create(namae: 'YT-202  フタ', zairyou:'フタ', cost: 65.0, divisor: 1, history: {})
		yt202samurai_lid = Material.create(namae: 'YT-202(サムライ)  フタ', zairyou:'フタ', cost: 77.0, divisor: 1, history: {})
		yt202gokujyoblue_lid = Material.create(namae: 'YT-202(極上青)  フタ', zairyou:'フタ', cost: 77.0, divisor: 1, history: {})
		yt202gokujyogreen_lid = Material.create(namae: 'YT-202(極上緑)  フタ', zairyou:'フタ', cost: 77.0, divisor: 1, history: {})
		yt202red_lid = Material.create(namae: 'YT-202(赤)  フタ', zairyou:'フタ', cost: 77.0, divisor: 1, history: {})
		yt202green_lid = Material.create(namae: 'YT-202(緑)  フタ', zairyou:'フタ', cost: 77.0, divisor: 1, history: {})
		yt202_box = Material.create(namae: 'YT-202', zairyou:'箱', cost: 95.0, divisor: 1, history: {})
		# Wide pack 20-pack box
		yt203_lid = Material.create(namae: 'YT-203  フタ', zairyou:'フタ', cost: 66.0, divisor: 1, history: {})
		yt203samurai_lid = Material.create(namae: 'YT-203(サムライ)  フタ', zairyou:'フタ', cost: 76.0, divisor: 1, history: {})
		yt203gokujyoblue_lid = Material.create(namae: 'YT-203(極上青)  フタ', zairyou:'フタ', cost: 76.0, divisor: 1, history: {})
		yt203gokujyogreen_lid = Material.create(namae: 'YT-203(極上緑)  フタ', zairyou:'フタ', cost: 76.0, divisor: 1, history: {})
		yt203_box = Material.create(namae: 'YT-203', zairyou:'箱', cost: 92.0, divisor: 1, history: {})
		# 5k Box with holes
		yt21gokujyoblue_lid = Material.create(namae: 'YT-21(極上青)  フタ', zairyou:'フタ', cost: 63.0, divisor: 1, history: {})
		yt21gokujyogreen_lid = Material.create(namae: 'YT-21(極上緑)  フタ', zairyou:'フタ', cost: 63.0, divisor: 1, history: {})
		yt21red_lid = Material.create(namae: 'YT-21(赤)  フタ', zairyou:'フタ', cost: 63.0, divisor: 1, history: {})
		yt21_box = Material.create(namae: 'YT-21（穴あき）', zairyou:'箱', cost: 103.0, divisor: 1, history: {})
		# Wide pac 30-pack box
		yt27_lid = Material.create(namae: 'YT-27  フタ', zairyou:'フタ', cost: 61.0, divisor: 1, history: {})
		yt27gokujyogreen_lid = Material.create(namae: 'YT-27(極上緑)  フタ', zairyou:'フタ', cost: 71.0, divisor: 1, history: {})
		yt27red_lid = Material.create(namae: 'YT-27(赤)  フタ', zairyou:'フタ', cost: 71.0, divisor: 1, history: {})
		yt27_box = Material.create(namae: 'YT-27', zairyou:'箱', cost: 99.0, divisor: 1, history: {})
		# Big tube 10-tube box
		yt28gokujyoblue_lid = Material.create(namae: 'YT-28(極上青)  フタ', zairyou:'フタ', cost: 76.0, divisor: 1, history: {})
		yt28gokujyogreen_lid = Material.create(namae: 'YT-28(極上緑)  フタ', zairyou:'フタ', cost: 76.0, divisor: 1, history: {})
		yt28_box = Material.create(namae: 'YT-28', zairyou:'箱', cost: 113.0, divisor: 1, history: {})
		# Chyubukuro 10-tube small box
		yt35_lid = Material.create(namae: 'YT-35  フタ', zairyou:'フタ', cost: 55.0, divisor: 1, history: {})
		yt35_box = Material.create(namae: 'YT-35', zairyou:'箱', cost: 81.0, divisor: 1, history: {})
		# 1k 10-pack box lid (seperated for some reason)
		yt100_lid = Material.create(namae: 'YT-100  フタ', zairyou:'フタ', cost: 114.0, divisor: 1, history: {})
		# 500g "jumbo pack" 12-pack box
		yt60gokujyoblue_lid = Material.create(namae: 'YT-60(極上青)  フタ', zairyou:'フタ', cost: 80.0, divisor: 1, history: {})
		yt60gokujyogreen_lid = Material.create(namae: 'YT-60(極上緑)  フタ', zairyou:'フタ', cost: 80.0, divisor: 1, history: {})
		yt60ashi_lid = Material.create(namae: 'YT-60(足付き)  フタ', zairyou:'フタ', cost: 70.0, divisor: 1, history: {})
		yt60ashisamurai_lid = Material.create(namae: 'YT-60(サムライ・足付き)  フタ', zairyou:'フタ', cost: 80.0, divisor: 1, history: {})
		yt60_box = Material.create(namae: 'YT-60', zairyou:'箱', cost: 126.0, divisor: 1, history: {})
		# 1k 6-pack box
		yt9s1samurai_lid = Material.create(namae: 'YT-9S-1(サムライ)  フタ', zairyou:'フタ', cost: 75.0, divisor: 1, history: {})
		yt9s1gokujyogreen_lid = Material.create(namae: 'YT-9S-1(極上緑)  フタ', zairyou:'フタ', cost: 75.0, divisor: 1, history: {})
		yt9s1_box = Material.create(namae: 'YT-9S-1', zairyou:'箱', cost: 115.0, divisor: 1, history: {})
		yt9s1_lid = Material.create(namae: 'YT-9S-1  フタ', zairyou:'フタ', cost: 65.0, divisor: 1, history: {})
		# 4-pack Mizukiri layering box
		mizukiri4_lid = Material.create(namae: '水切り 4パックトレイ(極上青)  フタ', zairyou:'フタ', cost: 65.0, divisor: 1, history: {})
		mizukiri4_box = Material.create(namae: '水切り 4パックトレイ', zairyou:'箱', cost: 62.0, divisor: 1, history: {})
		# 500g and 300g square pack support trays
		p300_tray_box = Material.create(namae: '500g ジャンボパック トレイ', zairyou:'箱', cost: 16, divisor: 1, history: {})
		p500_tray_box = Material.create(namae: '300g ジャンボパック トレイ', zairyou:'箱', cost: 18, divisor: 1, history: {})
		# 1k small box
		onekbox_lid = Material.create(namae: '1k箱 Lid', zairyou:'フタ', cost: 37.0, divisor: 1, history: {})
		onekbox_box = Material.create(namae: '1k箱 Box', zairyou:'箱', cost: 29.0, divisor: 1, history: {})
		twokbox_box = Material.create(namae: '2k箱 ', zairyou:'箱', cost: 36.0, divisor: 1, history: {})
		# frozen shel cardboard box
		fs_cardbord_box = Material.create(namae: '2k箱 ', zairyou:'箱', cost: 36.0, divisor: 1, history: {})
	# PACK TRAY #
	 	jumbo_tray = Material.create(namae: 'ジャンボパック(500g)　トレイ', zairyou:'トレイ', cost: 16, divisor: 1, history: {})
	 	jumbos_tray = Material.create(namae: 'ジャンボパック(300g)　トレイ', zairyou:'トレイ', cost: 16, divisor: 1, history: {})
	 	wide_tray = Material.create(namae: 'ワイドパック　トレイ', zairyou:'トレイ', cost: 7, divisor: 1, history: {})
	 	wide_tray = Material.create(namae: 'ワイドパック 8粒 トレイ', zairyou:'トレイ', cost: 12, divisor: 1, history: {})
	 	regular_tray = Material.create(namae: 'レギュラーパック　トレイ', zairyou:'トレイ', cost: 4, divisor: 1, history: {})
	 	mizukiri500_tray = Material.create(namae: '水切りパック（500g）　トレイ', zairyou:'トレイ', cost: 35, divisor: 1, history: {})
	 	mizukiri200_tray = Material.create(namae: 'ジャンボパック（200g）　トレイ', zairyou:'トレイ', cost: 30, divisor: 1, history: {})
	 	mizukirilid_tray = Material.create(namae: '水切りパック フタ', zairyou:'トレイ', cost: 25, divisor: 1, history: {})
		# 5 Kilo can and lid
	 	fivek_can = Material.create(namae: '5キロ缶 缶 本体＋フタ', zairyou:'トレイ', cost: 185, divisor: 1, history: {})
	# PACK FILM #
		jumbo_film1 = Material.create(namae: 'ジャンボパック　(500g 生)　フィルム', zairyou:'フィルム', cost: 15.9, divisor: 4, history: {})
		jumbo_film2 = Material.create(namae: 'ジャンボパック　(500g 加)　フィルム', zairyou:'フィルム', cost: 15.9, divisor: 4, history: {})
		jumbo_film3 = Material.create(namae: 'ジャンボパック　(300g 生)　フィルム', zairyou:'フィルム', cost: 15.9, divisor: 4, history: {})
		jumbo_film4 = Material.create(namae: 'ジャンボパック　(300g 坂越　加)　フィルム', zairyou:'フィルム', cost: 15.9, divisor: 4, history: {})
		wide_film1 = Material.create(namae: 'ワイドパック　(坂越 生)　フィルム', zairyou:'フィルム', cost: 14.2, divisor: 6, history: {})
		wide_film2 = Material.create(namae: 'ワイドパック　(サムライ 生)　フィルム', zairyou:'フィルム', cost: 14.2, divisor: 6, history: {})
		wide_film3 = Material.create(namae: 'ワイドパック　(サムライ 加)　フィルム', zairyou:'フィルム', cost: 13.3, divisor: 6, history: {})
		wide_film4 = Material.create(namae: 'ワイドパック　(大粒 生)　フィルム', zairyou:'フィルム', cost: 14.2, divisor: 6, history: {})
		wide_film5 = Material.create(namae: 'ワイドパック　(サムライ黒 生)　フィルム', zairyou:'フィルム', cost: 14.2, divisor: 6, history: {})
		wide_film6 = Material.create(namae: 'ワイドパック　(サムライ黒 加)　フィルム', zairyou:'フィルム', cost: 13.3, divisor: 6, history: {})
		regular_film1 = Material.create(namae: 'レギュラーパック　(坂越 生)　フィルム', zairyou:'フィルム', cost: 12.6, divisor: 6, history: {})
		regular_film2 = Material.create(namae: 'レギュラーパック　(サムライ 生)　フィルム', zairyou:'フィルム', cost: 12.6, divisor: 6, history: {})
		regular_film3 = Material.create(namae: 'レギュラーパック　(サムライ 加)　フィルム', zairyou:'フィルム', cost: 11.8, divisor: 6, history: {})
		regular_film4 = Material.create(namae: 'レギュラーパック　(無地　氷用)　フィルム', zairyou:'フィルム', cost: 11.5, divisor: 6, history: {})
		regular_film5 = Material.create(namae: 'レギュラーパック　(サムライ黒 生)　フィルム', zairyou:'フィルム', cost: 12.3, divisor: 6, history: {})
		regular_film6 = Material.create(namae: 'レギュラーパック　(サムライ黒 加)　フィルム', zairyou:'フィルム', cost: 11.8, divisor: 6, history: {})
		c2_bigtube_film = Material.create(namae: '二色　大袋　フィルム', zairyou:'フィルム', cost: 7.3, divisor: 1, history: {})
		c3_bigtube_film = Material.create(namae: '無地　大袋　フィルム', zairyou:'フィルム', cost: 5.0, divisor: 1, history: {})
		c2_tube_film = Material.create(namae: '二色　中袋　フィルム', zairyou:'フィルム', cost: 4.5, divisor: 1, history: {})
		c3_tube_film = Material.create(namae: '三色　中袋　フィルム', zairyou:'フィルム', cost: 5, divisor: 1, history: {})
	# BAGS #
	 	fivek_bag = Material.create(namae: '5キロ缶　入れ袋', zairyou:'袋', cost: 5.6, divisor: 1, history: {})
	 	onek_bag = Material.create(namae: '1キロ弁当箱　入れ袋', zairyou:'袋', cost: 3.5, divisor: 1, history: {})
	 	protonshell_bag = Material.create(namae: 'プロトン冷凍セル　入れ袋', zairyou:'袋', cost: 0, divisor: 1, history: {})
	 	protonmukimi_bag = Material.create(namae: 'プロトン冷凍デカプリオイスター　入れ袋', zairyou:'袋', cost: 0, divisor: 1, history: {})
	# ICE/BAND/OTHER #
	 	small_ice = Material.create(namae: '粒氷（小-0.5)', zairyou:'粒氷', cost: 30, divisor: 1, history: {})
	 	medium_ice = Material.create(namae: '粒氷（並-1）', zairyou:'粒氷', cost: 50, divisor: 1, history: {})
	 	large_ice = Material.create(namae: '粒氷（大-1.5）', zairyou:'粒氷', cost: 70, divisor: 1, history: {})
	 	one_band = Material.create(namae: 'ブルーバンド（1回）', zairyou:'バンド', cost: 2, divisor: 1, history: {})
	 	two_band = Material.create(namae: 'ブルーバンド（2回）', zairyou:'バンド', cost: 5, divisor: 1, history: {})
	 	three_band = Material.create(namae: 'ブルーバンド（3回）', zairyou:'バンド', cost: 7, divisor: 1, history: {})
	 	four_band = Material.create(namae: 'ブルーバンド（4回）', zairyou:'バンド', cost: 10, divisor: 1, history: {})
	 	tube_clip = Material.create(namae: 'プラスチックチューブのクリップ', zairyou:'バンド', cost: 1.4, divisor: 1, history: {})
	 	rubber_band = Material.create(namae: '輪ゴム', zairyou:'バンド', cost: 5, divisor: 1, history: {})
	 	iinji_label = Material.create(namae: '印字', zairyou:'ラベル', cost: 10, divisor: 1, history: {})
	 	tiny_label = Material.create(namae: '白プリントラベル（小）25x15', zairyou:'ラベル', cost: 5, divisor: 1, history: {})
	 	normal_label = Material.create(namae: '白プリントラベル（並）28x40', zairyou:'ラベル', cost: 10, divisor: 1, history: {})
	 	medium_label = Material.create(namae: '白プリントラベル（中）40x46', zairyou:'ラベル', cost: 10, divisor: 1, history: {})
	 	large_label = Material.create(namae: '白プリントラベル（大）50x55', zairyou:'ラベル', cost: 20, divisor: 1, history: {})


# PRODUCTS #
	# Hand packed
		Product.create(namae: '5キロ缶 (2入り)[㊐ー日生―特大]{船曳青}', grams: 10050.0, cost: 600.0, extra_expense: 0.0, product_type: '水切り', count: 2, multiplier: 1, history: {})
		Product.create(namae: '5キロ缶 (2入り)[㊐ー日生ー大多府]{紺}', grams: 10050.0, cost: 600.0, extra_expense: 0.0, product_type: '水切り', count: 2, multiplier: 1, history: {})
		Product.create(namae: '5キロ缶 (2入り)[㋔ー邑久―並]{茶}', grams: 5025.0, cost: 600.0, extra_expense: 0.0, product_type: '水切り', count: 2, multiplier: 1, history: {})
		Product.create(namae: '5キロ缶 (2入り)[㋔ー邑久ー小]{赤}', grams: 5025.0, cost: 600.0, extra_expense: 0.0, product_type: '水切り', count: 2, multiplier: 1, history: {})
		Product.create(namae: '5キロ缶 (2入り)[㋑ー伊里ー並]{オレンジ}', grams: 5025.0, cost: 600.0, extra_expense: 0.0, product_type: '水切り', count: 2, multiplier: 1, history: {})
		Product.create(namae: '5キロ缶 (2入り)[㋚ー坂越ー並]{緑}', grams: 5025.0, cost: 600.0, extra_expense: 0.0, product_type: '水切り', count: 2, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (10入り) ㋕', grams: 1025.0, cost: 1020.0, extra_expense: 0.0, product_type: '水切り', count: 10, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (6入り) ㋕', grams: 1025.0, cost: 650.0, extra_expense: 0.0, product_type: '水切り', count: 6, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (10入り)', grams: 1025.0, cost: 1020.0, extra_expense: 0.0, product_type: '水切り', count: 10, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (9入り)', grams: 1025.0, cost: 1000.0, extra_expense: 0.0, product_type: '水切り', count: 9, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (8入り)', grams: 1025.0, cost: 890.0, extra_expense: 0.0, product_type: '水切り', count: 8, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (7入り)', grams: 1025.0, cost: 820.0, extra_expense: 0.0, product_type: '水切り', count: 8, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (6入り)', grams: 1025.0, cost: 650.0, extra_expense: 0.0, product_type: '水切り', count: 6, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (5入り)', grams: 1025.0, cost: 600.0, extra_expense: 0.0, product_type: '水切り', count: 5, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (4入り)', grams: 1025.0, cost: 500.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (3入り)', grams: 1025.0, cost: 400.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 1, history: {})
		Product.create(namae: '1キロ弁当箱 (2入り)', grams: 1025.0, cost: 350.0, extra_expense: 0.0, product_type: '水切り', count: 2, multiplier: 1, history: {})
		Product.create(namae: '500g水切りパック (4x7)', grams: 515.0, cost: 2460.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 7, history: {})
		Product.create(namae: '500g水切りパック (4x6)', grams: 515.0, cost: 2220.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 6, history: {})
		Product.create(namae: '500g水切りパック (4x5)', grams: 515.0, cost: 1780.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 5, history: {})
		Product.create(namae: '500g水切りパック (4x4)', grams: 515.0, cost: 1440.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 4, history: {})
		Product.create(namae: '500g水切りパック (4x3)', grams: 515.0, cost: 1100.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 3, history: {})
		Product.create(namae: '500g水切りパック (4x2)', grams: 515.0, cost: 750.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 2, history: {})
		Product.create(namae: '500g水切りパック (4x1)', grams: 515.0, cost: 420.0, extra_expense: 0.0, product_type: '水切り', count: 4, multiplier: 1, history: {})
		Product.create(namae: '200g水切りパック (20x1)', grams: 215.0, cost: 1550.0, extra_expense: 0.0, product_type: '水切り', count: 20, multiplier: 1, history: {})
		Product.create(namae: '200g水切りパック (20x2)', grams: 215.0, cost: 3060.0, extra_expense: 0.0, product_type: '水切り', count: 20, multiplier: 2, history: {})
		Product.create(namae: '200g水切りパック (10x1)', grams: 215.0, cost: 1550.0, extra_expense: 0.0, product_type: '水切り', count: 20, multiplier: 1, history: {})
	# トレイs
		Product.create(namae: '500gジャンボパック(12入り)', grams: 450.0, cost: 700.0, extra_expense: 0.0, product_type: 'トレイ', count: 12, multiplier: 1, history: {})
		Product.create(namae: '500gジャンボパック(16入り)', grams: 450.0, cost: 900.0, extra_expense: 0.0, product_type: 'トレイ', count: 16, multiplier: 1, history: {})
		Product.create(namae: '300gジャンボパック (20入り)', grams: 275.0, cost: 1150.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 1, history: {})
		Product.create(namae: '300gジャンボパック (12入り)', grams: 275.0, cost: 720.0, extra_expense: 0.0, product_type: 'トレイ', count: 12, multiplier: 1, history: {})
		Product.create(namae: '300gジャンボパック (6入り)', grams: 275.0, cost: 460.0, extra_expense: 0.0, product_type: 'トレイ', count: 6, multiplier: 1, history: {})
		Product.create(namae: '120gワイドパック (20x3)ⓢ', grams: 101.0, cost: 1140.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 3, history: {})
		Product.create(namae: '120gワイドパック (20x2)ⓢ', grams: 101.0, cost: 760.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 2, history: {})
		Product.create(namae: '120gワイドパック (20x1)ⓢ', grams: 101.0, cost: 400.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 1, history: {})
		Product.create(namae: '120gワイドパック (20x3)㋚', grams: 101.0, cost: 1140.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 3, history: {})
		Product.create(namae: '120gワイドパック (20x2)㋚', grams: 101.0, cost: 760.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 2, history: {})
		Product.create(namae: '120gワイドパック (20x1)㋚', grams: 101.0, cost: 400.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 1, history: {})
		Product.create(namae: '100gレギュラーパック (30x1)', grams: 85.0, cost: 800.0, extra_expense: 0.0, product_type: 'トレイ', count: 30, multiplier: 1, history: {})
		Product.create(namae: '100gレギュラーパック (30x2)', grams: 85.0, cost: 400.0, extra_expense: 0.0, product_type: 'トレイ', count: 30, multiplier: 2, history: {})
		Product.create(namae: '100gレギュラーパック (20x3)', grams: 85.0, cost: 940.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 3, history: {})
		Product.create(namae: '100gレギュラーパック (20x2)', grams: 85.0, cost: 630.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 2, history: {})
		Product.create(namae: '100gレギュラーパック (20x1)', grams: 85.0, cost: 330.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 1, history: {})
		Product.create(namae: '8粒ワイドパック (20x2)', grams: 115.0, cost: 1120.0, extra_expense: 0.0, product_type: 'トレイ', count: 20, multiplier: 2, history: {})
		Product.create(namae: '8粒ワイドパック (10x3)', grams: 115.0, cost: 1000.0, extra_expense: 0.0, product_type: 'トレイ', count: 10, multiplier: 3, history: {})
		Product.create(namae: '8粒ワイドパック (10x2)', grams: 115.0, cost: 670.0, extra_expense: 0.0, product_type: 'トレイ', count: 10, multiplier: 2, history: {})
	# チューブs
		Product.create(namae: '大袋（10入り）㋚', grams: 450.0, cost: 350.0, extra_expense: 0.0, product_type: 'チューブ', count: 10, multiplier: 1, history: {})
		Product.create(namae: '大袋（10入り）㋔', grams: 450.0, cost: 350.0, extra_expense: 0.0, product_type: 'チューブ', count: 10, multiplier: 1, history: {})
		Product.create(namae: '大袋（10入り）特', grams: 450.0, cost: 350.0, extra_expense: 0.0, product_type: 'チューブ', count: 10, multiplier: 1, history: {})
		Product.create(namae: '中袋（20入り）㋚', grams: 101.0, cost: 380.0, extra_expense: 0.0, product_type: 'チューブ', count: 20, multiplier: 1, history: {})
		Product.create(namae: '中袋（20入り）㋔', grams: 101.0, cost: 380.0, extra_expense: 0.0, product_type: 'チューブ', count: 20, multiplier: 1, history: {})
		Product.create(namae: '中袋（20入り）㋚㋕', grams: 101.0, cost: 380.0, extra_expense: 0.0, product_type: 'チューブ', count: 20, multiplier: 1, history: {})
		Product.create(namae: '中袋（20入り）㋔㋕', grams: 101.0, cost: 380.0, extra_expense: 0.0, product_type: 'チューブ', count: 20, multiplier: 1, history: {})
		Product.create(namae: '中袋（10x3）', grams: 85.0, cost: 730.0, extra_expense: 0.0, product_type: 'チューブ', count: 10, multiplier: 3, history: {})
		Product.create(namae: '中袋（10x2）', grams: 85.0, cost: 500.0, extra_expense: 0.0, product_type: 'チューブ', count: 10, multiplier: 2, history: {})
		Product.create(namae: '中袋（10入り）', grams: 85.0, cost: 250.0, extra_expense: 0.0, product_type: 'チューブ', count: 10, multiplier: 1, history: {})
	# 殻付き
		Product.create(namae: 'セル（坂越 30x6)', grams: 0, cost: 950.0, extra_expense: 0.0, product_type: '殻付き', count: 30, multiplier: 4, history: {})
		Product.create(namae: 'セル（坂越 30x4)', grams: 0, cost: 650.0, extra_expense: 0.0, product_type: '殻付き', count: 30, multiplier: 4, history: {})
		Product.create(namae: 'WDI - セル（坂越）', grams: 0, cost: 400.0, extra_expense: 0.0, product_type: '殻付き', count: 150, multiplier: 1, history: {})
	# 冷凍
		Product.create(namae: 'プロトン冷凍セル', grams: 0, cost: 400.0, extra_expense: 0.0, product_type: '冷凍', count: 100, multiplier: 1, history: {})
		Product.create(namae: 'プロトン冷凍　デカプリオイスター', grams: 505.0, cost: 0.0, extra_expense: 0.0, product_type: '冷凍', count: 20, multiplier: 1, history: {})


# MARKETS #
# cost is all costs currently #
	# "Jyounai", "Touhatsu", "Syouei"
		Market.create(mjsnumber: 1000, namae: '東都水産株式会社', nick: '東水', zip: '135-8134', address:'東京都江東区豊洲６-６-２', phone: '03-3542-1111', repphone: '000-000-0000', fax: '03-6633-1045', cost: 400.0, block_cost: 175.0, one_time_cost: 480.0, one_time_cost_description: "送信料・送金料", optional_cost: 356.0, optional_cost_description: "冷凍別送信料", history: {}, 
products: Product.where(namae: [
'120gワイドパック (20x2)',
'100gレギュラーパック (20x3)', 
'8粒ワイドパック (20x2)', 
'8粒ワイドパック (10x3)', 
'8粒ワイドパック (10x2)', 
'5キロ缶 (2入り)[㊐ー日生―特大]{船曳青}',
'5キロ缶 (2入り)[㊐ー日生ー大多府]{紺}',
'5キロ缶 (2入り)[㋔ー邑久―並]{茶}',
'5キロ缶 (2入り)[㋔ー邑久ー小]{赤}',
'5キロ缶 (2入り)[㋑ー伊里ー並]{オレンジ}',
'5キロ缶 (2入り)[㋚ー坂越ー並]{緑}',
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'セル（坂越 30x4)', 
'WDI - セル（坂越）', 
'プロトン冷凍　デカプリオイスター']))
Market.create(mjsnumber: 1002, namae: '船橋魚市株式会社', nick: '船橋', zip: '273-0001', address:'千葉県船橋市市場１丁目８番１号　船橋市地方卸売市場内', phone: '03-3542-1111', repphone: '000-000-0000', fax: '000-000-0000', cost: 400.0, block_cost: 400.0, one_time_cost: 190.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {}, 
products: Product.where(namae: [
'500gジャンボパック(12入り)',
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'5キロ缶 (2入り)[㊐ー日生―特大]{船曳青}',
'5キロ缶 (2入り)[㊐ー日生ー大多府]{紺}',
'5キロ缶 (2入り)[㋔ー邑久―並]{茶}',
'5キロ缶 (2入り)[㋔ー邑久ー小]{赤}',
'5キロ缶 (2入り)[㋑ー伊里ー並]{オレンジ}',
'5キロ缶 (2入り)[㋚ー坂越ー並]{緑}',
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)',
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1003, namae: '前橋水産物商業協同組合', nick: '前橋', zip: '371-0012', address:'群馬県前橋市東片貝町３９３－１', phone: '027-261-3111', repphone: '000-000-0000', fax: '027-261-4851', cost: 400.0, block_cost: 330.0, one_time_cost: 260.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {}, 
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)',
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1005, namae: '横浜丸魚株式会本場', nick: '横浜', zip: '221-0054', address:'横浜市神奈川区山内町1 横浜市中央卸売市場内', phone: '045-459-2921', repphone: '000-000-0000', fax: '045-459-2898', cost: 400.0, block_cost: 290.0, one_time_cost: 360.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {}, 
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'500gジャンボパック(12入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'5キロ缶 (2入り)[㊐ー日生―特大]{船曳青}',
'5キロ缶 (2入り)[㊐ー日生ー大多府]{紺}',
'5キロ缶 (2入り)[㋔ー邑久―並]{茶}',
'5キロ缶 (2入り)[㋔ー邑久ー小]{赤}',
'5キロ缶 (2入り)[㋑ー伊里ー並]{オレンジ}',
'5キロ缶 (2入り)[㋚ー坂越ー並]{緑}',
'セル（坂越 30x4)']))
Market.create(mjsnumber: 1007, namae: '株式会社埼玉県魚市場', nick: '埼玉', zip: '331-9675', address:'埼玉県さいたま市北区吉野町２丁目２２６番地１', phone: '048-666－3101', repphone: '000-000-0000', fax: '000-000-0000', cost: 400.0, block_cost: 270.0, one_time_cost: 97.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'大袋',
'5キロ缶 (2入り)[㊐ー日生―特大]{船曳青}',
'5キロ缶 (2入り)[㊐ー日生ー大多府]{紺}',
'5キロ缶 (2入り)[㋔ー邑久―並]{茶}',
'5キロ缶 (2入り)[㋔ー邑久ー小]{赤}',
'5キロ缶 (2入り)[㋑ー伊里ー並]{オレンジ}',
'5キロ缶 (2入り)[㋚ー坂越ー並]{緑}', 
'セル（坂越 30x4)']))
Market.create(mjsnumber: 1008, namae: '群馬魚類株式会社', nick: '群馬魚市', zip: '371-0012', address:'群馬県前橋市東片貝町３９２', phone: '027-261-3211', repphone: '000-000-0000', fax: '000-000-0000', cost: 400.0, block_cost: 330.0, one_time_cost: 115.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)']))
		Market.create(mjsnumber: 1009, namae: '株式会社群馬県水産市場', nick: '群馬県水', zip: '370-0034', address:'群馬県高崎市下大類町１２５８番地', phone: '027-352-5515', repphone: '000-000-0000', fax: '027-352-1933', cost: 400.0, block_cost: 330.0, one_time_cost: 115.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'大袋', 
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'セル（坂越 30x6)',
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1010, namae: '株式会社海商水産', nick: '海商', zip: '379-2311', address:'群馬県みどり市笠懸町阿佐美２７６１－１', phone: '0277-76-4571', repphone: '000-000-0000', fax: '0277-76-7901', cost: 400.0, block_cost: 380.0, one_time_cost: 150.0, one_time_cost_description: "送信料・送金料", optional_cost: 50.0, optional_cost_description: "YT-101のプラス¥50送料", history: {},
products: Product.where(namae: [
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)',
'5キロ缶 (2入り)[㊐ー日生―特大]{船曳青}',
'5キロ缶 (2入り)[㊐ー日生ー大多府]{紺}',
'5キロ缶 (2入り)[㋔ー邑久―並]{茶}',
'5キロ缶 (2入り)[㋔ー邑久ー小]{赤}',
'5キロ缶 (2入り)[㋑ー伊里ー並]{オレンジ}',
'5キロ缶 (2入り)[㋚ー坂越ー並]{緑}', 
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1011, namae: '茨城水産株式会社', nick: '茨城', zip: '310-0004', address:'茨城県水戸市青柳町４５６６', phone: '029-227-2121', repphone: '000-000-0000', fax: '029-227-1041', cost: 400.0, block_cost: 390.0, one_time_cost: 216.0, one_time_cost_description: "送信料・送金料", optional_cost: 50.0, optional_cost_description: "YT-101のプラス¥50送料", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'500gジャンボパック(12入り)', 
'300gジャンボパック (20入り)', 
'300gジャンボパック (12入り)', 
'300gジャンボパック (6入り)', 
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1012, namae: '常洋水産株式会社土浦支社', nick: '土浦', zip: '300-0847', address:'茨城県土浦市卸町１丁目１０番１号', phone: '029-842-9370', repphone: '000-000-0000', fax: '029-842-0442', cost: 400.0, block_cost: 490.0, one_time_cost: 415.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'500gジャンボパック(12入り)', ]))
		Market.create(mjsnumber: 1013, namae: '千葉中央魚類株式会社', nick: '千葉', zip: '261-0003', address:'千葉県美浜区高浜２丁目２番１号', phone: '043-248-3418', repphone: '000-000-0000', fax: '043-248-3701', cost: 400.0, block_cost: 340.0, one_time_cost: 378.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'500gジャンボパック(12入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)',
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1014, namae: '株式会社宮市', nick: '宮市', zip: '321-0933', address:'栃木県宇都宮市簗瀬町１４９３番地', phone: '028-637-6666', repphone: '000-000-0000', fax: '028-637-6660', cost: 400.0, block_cost: 368.0, one_time_cost: 210.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500gジャンボパック(12入り)']))
Market.create(mjsnumber: 1015, namae: '足利海産株式会社', nick: '足利', zip: '326-0338', address:'栃木県足利市福居町２５４－１', phone: '0284-72-6605', repphone: '000-000-0000', fax: '000-000-0000', cost: 400.0, block_cost: 500.0, one_time_cost: 120.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500gジャンボパック(12入り)', 
'5キロ缶 (2入り)']))
		Market.create(mjsnumber: 1016, namae: '株式会社小田原魚市場', nick: '小田原', zip: '250-0021', address:'神奈川県小田原市早川１丁目１０番地１', phone: '0465-22-8131', repphone: '000-000-0000', fax: '0465-23-2210', cost: 400.0, block_cost:315.0, one_time_cost: 490.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'1キロ弁当箱 (10入り)']))
		Market.create(mjsnumber: 1017, namae: '甲府中央魚市株式会社', nick: '甲府', zip: '400-0043', address:'山梨県甲府市国母６丁目５番１号', phone: '055-228-0111', repphone: '000-000-0000', fax: '055-228-4388', cost: 400.0, block_cost: 400.0, one_time_cost: 352.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500gジャンボパック(12入り)', 
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'大袋']))
		Market.create(mjsnumber: 1018, namae: '沼津魚市場株式会社', nick: '沼津', zip: '410-0845', address:'静岡県沼津市千本港町１２８－３', phone: '055-962-3700', repphone: '000-000-0000', fax: '055-951-6851', cost: 280.0, block_cost: 340.0, one_time_cost: 170.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'中袋（20入り）']))
		Market.create(mjsnumber: 1019, namae: '魚市静岡魚市株式会社', nick: '静岡', zip: '420-0922', address:'静岡県静岡市葵区流通センター１番１号', phone: '054-263-3281', repphone: '000-000-0000', fax: '054-263-3270', cost: 280.0, block_cost: 490.0, one_time_cost: 324.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'100gレギュラーパック (20x3)', 
'100gレギュラーパック (20x2)', 
'100gレギュラーパック (20x1)', 
'大袋', 
'中袋（20入り）', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)',
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1020, namae: '丸水秋田中央水産株式会社', nick: '秋田', zip: '010-0802', address:'秋田県秋田市外旭川字待合２８番地', phone: '018-869-5311', repphone: '000-000-0000', fax: '018-868-1931', cost: 400.0, block_cost: 575.0, one_time_cost: 432.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
]))
		Market.create(mjsnumber: 1023, namae: '株式会社湯沢水産地方卸売市場', nick: '湯沢', zip: '012-0813', address:'秋田県湯沢市前森３丁目８番１７号', phone: '0183-72-2111', repphone: '000-000-0000', fax: '0183-73-2158', cost: 400.0, block_cost: 575.0, one_time_cost: 432.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)']))
		Market.create(mjsnumber: 1024, namae: 'いわき魚類株式会社', nick: 'いわき', zip: '971-8139', address:'福島県いわき市鹿島町鹿島１番地', phone: '0246-29-6565', repphone: '000-000-0000', fax: '0246-29-6961', cost: 400.0, block_cost: 520.0, one_time_cost: 622.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'100gレギュラーパック (20x3)', 
'100gレギュラーパック (20x2)', 
'100gレギュラーパック (20x1)',
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'大袋', 
'中袋（20入り）', 
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1025, namae: '株式会社福島丸公', nick: '福島', zip: '960-0113', address:'福島県福島市北矢野目字樋越１番地（福島市中央卸売市場内）', phone: '024-553-1111', repphone: '000-000-0000', fax: '024-553-7442', cost: 400.0, block_cost: 575.0, one_time_cost: 350.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'100gレギュラーパック (20x3)', 
'100gレギュラーパック (20x2)', 
'100gレギュラーパック (20x1)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'中袋（20入り）',
'セル（坂越 30x4)']))
	# Niigata (Yamatsu Kakujyou)
Market.create(mjsnumber: 1027, namae: '山津水産株式会社', nick: '山津', zip: '950-0114', address:'新潟県新潟市江南区茗荷谷７１１番地', phone: '025-257-6600', repphone: '000-000-0000', fax: '000-000-0000', cost: 930.0, block_cost: 50.0, one_time_cost: 425.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'300gジャンボパック (20入り)', 
'300gジャンボパック (12入り)',
'100gレギュラーパック (20x3)', 
'100gレギュラーパック (20x2)', 
'100gレギュラーパック (20x1)', 
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'セル（坂越 30x4)']))
	# "Touhatsu" Continued (Nihonkai side)
		Market.create(mjsnumber: 1031, namae: '株式会社手塚商店', nick: '手塚', zip: '997-0035', address:'山形県鶴岡市馬場町７番８号', phone: '0235-24-3335', repphone: '000-000-0000', fax: '0235-24-3337', cost: 400.0, block_cost: 600.0, one_time_cost: 340.0, one_time_cost_description: "送信料・送金料", optional_cost: 50.0, optional_cost_description: "YT-101のプラス¥50送料", history: {},
products: Product.where(namae: [
'300gジャンボパック (20入り)']))
		Market.create(mjsnumber: 1032, namae: '日本海水産株式会社', nick: '日本海', zip: '998-0036', address:'山形県酒田市船場町２丁目２番１８号', phone: '0234-22-2750', repphone: '000-000-0000', fax: '0234-22-2843', cost: 400.0, block_cost: 620.0, one_time_cost: 400.0, one_time_cost_description: "送信料・送金料", optional_cost: 50.0, optional_cost_description: "YT-101のプラス¥50送料", history: {},
products: Product.where(namae: [
'300gジャンボパック (20入り)',
'大袋']))
	# Niigata Continued (Nagaoka)
		Market.create(mjsnumber: 1033, namae: '長岡中央水産株式会社', nick: '長岡水産', zip: '940-2127', address:'新潟県長岡市新産１丁目１番地３', phone: '0258-46-4343', repphone: '000-000-0000', fax: '0258-46-6656', cost: 930.0, block_cost: 0.0, one_time_cost: 125.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'300gジャンボパック (20入り)']))
		Market.create(mjsnumber: 1034, namae: '株式会社長岡中央魚市場', nick: '長岡魚市', zip: '940-0065', address:'新潟県長岡市坂之上町３丁目４番地１', phone: '0258-36-5611', repphone: '000-000-0000', fax: '0258-37-0285', cost: 930.0, block_cost: 0.0, one_time_cost: 125.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500gジャンボパック(12入り)']))
	# "Touhatsu" Continued (Kouriyama)
		Market.create(mjsnumber: 1035, namae: '株式会社郡山水産', nick: '郡山', zip: '963-0201', address:'福島県郡山市大槻町字向原１１４番地', phone: '024-966-0123', repphone: '000-000-0000', fax: '024-966-0150', cost: 400.0, block_cost: 440.0, one_time_cost: 200.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'100gレギュラーパック (20x3)', 
'100gレギュラーパック (20x2)', 
'100gレギュラーパック (20x1)',
'セル（坂越 30x4)']))
	# Kobe to Shizuoka (Nagoya, Ishikawa)
		Market.create(mjsnumber: 1036, namae: '石川中央魚市株式会社', nick: '石川', zip: '920-8691', address:'石川県金沢市西念４丁目７番１号', phone: '076-223-1381', repphone: '000-000-0000', fax: '076-263-6417', cost: 400.0, block_cost: 45.0, one_time_cost: 450.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'100gレギュラーパック (20x3)', 
'100gレギュラーパック (20x2)', 
'100gレギュラーパック (20x1)', 
'大袋', 
'中袋（20入り）', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'セル（坂越 30x4)']))
	# "Touhatsu" Continued
		Market.create(mjsnumber: 1037, namae: '横浜丸魚株式会社　川崎北部支社', nick: '川崎北部', zip: '216-0012', address:'川崎市宮前区水沢１丁目1番１号　川崎市中央卸売市場　北部市場', phone: '050-5541-6600', repphone: '000-000-0000', fax: '044-975-2757', cost: 400.0, block_cost: 350.0, one_time_cost: 464.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)',  
'100gレギュラーパック (20x3)', 
'100gレギュラーパック (20x2)', 
'100gレギュラーパック (20x1)',
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'5キロ缶 (2入り)[㊐ー日生―特大]{船曳青}',
'5キロ缶 (2入り)[㊐ー日生ー大多府]{紺}',
'5キロ缶 (2入り)[㋔ー邑久―並]{茶}',
'5キロ缶 (2入り)[㋔ー邑久ー小]{赤}',
'5キロ缶 (2入り)[㋑ー伊里ー並]{オレンジ}',
'5キロ缶 (2入り)[㋚ー坂越ー並]{緑}', 
'セル（坂越 30x4)']))
	# Kobe to Shizuoka (Nagoya, Hamamatsu, Ebisen) Continued
		Market.create(mjsnumber: 1200, namae: '浜松魚類株式会社', nick: '浜松', zip: '435-0023', address:'静岡県浜松市南区新貝町２３９番地の１', phone: '053-427-7301', repphone: '000-000-0000', fax: '053-427-7398', cost: 280.0, block_cost: 250.0, one_time_cost: 360.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'中袋（20入り）', 
'セル（坂越 30x4)', 
'5キロ缶 (2入り)']))
		Market.create(mjsnumber: 1202, namae: '株式会社海老仙', nick: '海老仙', zip: '431-0102', address:'静岡県浜松市西区雄踏町宇布見8962-5', phone: '053-592-1115', repphone: '000-000-0000', fax: '053-592-7118 ', cost: 280.0, block_cost: 250.0, one_time_cost: 360.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', ]))
Market.create(mjsnumber: 1220, namae: '名北魚市場株式会社', nick: '名北', zip: '480-0291', address:'愛知県西春日井郡豊山町豊場八反１０７', phone: '052-903-5202', repphone: '000-000-0000', fax: '000-000-0000', cost: 340.0, block_cost: 50.0, one_time_cost: 435.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'大袋', 
'中袋（20入り）',
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)',
'5キロ缶 (2入り)']))
Market.create(mjsnumber: 1221, namae: '大東魚類株式会社', nick: '大東', zip: '456-0072', address:'愛知県名古屋市熱田区川並町２番２２号', phone: '052-683-3323', repphone: '000-000-0000', fax: '000-000-0000', cost: 280.0, block_cost: 50.0, one_time_cost: 435.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'大袋', 
'中袋（20入り）', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)',  
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)',  
'セル（坂越 30x4)',
'5キロ缶 (2入り)']))
		Market.create(mjsnumber: 1222, namae: '魚錠水産株式会社', nick: '魚錠', zip: '480-0202', address:'愛知県西春日井郡豊山町大字豊場字八反１０７　名古屋市北部市場水産部　３階', phone: '052-903-2034', repphone: '000-000-0000', fax: '052-903-2485', cost: 280.0, block_cost: 0.0, one_time_cost: 0.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)']))
Market.create(mjsnumber: 1223, namae: '名古屋海産市場株式会社', nick: '丸海', zip: '567-0853', address:'愛知県名古屋市熱田区川並町２番２２号（名古屋市中央卸売市場内）', phone: '072-636-2281', repphone: '000-000-0000', fax: '000-000-0000', cost: 280.0, block_cost: 50.0, one_time_cost: 170.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'大袋', 
'中袋（20入り）' ,
'セル（坂越 30x4)']))
	# "Kansai" (Routed through Osaka)
Market.create(mjsnumber: 1241, namae: '株式会社うおいち北部', nick: '大⃝北', zip: '567-0853', address:'大阪府茨木市宮島1丁目１番1号　大阪府中央卸売市場内', phone: '072-636-2281', repphone: '000-000-0000', fax: '000-000-0000', cost: 220.0, block_cost: 60.0, one_time_cost: 355.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'大袋', 
'中袋（20入り）',
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'200g水切りパック (20x1)', 
'200g水切りパック (20x2)',  
'セル（坂越 30x4)']))
Market.create(mjsnumber: 1242, namae: '株式会社うおいち東部支社', nick: '大⃝東', zip: '546-0001', address:'大阪市東住吉区今林1丁目2番68号　大阪市中央卸売市場東部市場内', phone: '06-6756-2001', repphone: '000-000-0000', fax: '000-000-0000', cost: 220.0, block_cost: 60.0, one_time_cost: 355.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'大袋', 
'中袋（20入り）',
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'200g水切りパック (20x1)', 
'200g水切りパック (20x2)',  
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1245, namae: '株式会社うおいち大阪', nick: '大阪', zip: '553-8555', address:'大阪市福島区野田１丁目１番８６号　大阪市中央卸売市場内', phone: '06-6469-2005', repphone: '000-000-0000', fax: '06-6469-2155', cost: 220.0, block_cost: 60.0, one_time_cost: 355.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'100gレギュラーパック (30x1)', 
'100gレギュラーパック (30x2)',
'大袋', 
'中袋（20入り）',
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'200g水切りパック (20x1)', 
'200g水切りパック (20x2)',  
'セル（坂越 30x4)']))
	# "Daikuma" Kochi (Using Shinei from Osaka)	
		Market.create(mjsnumber: 1251, namae: '大熊水産株式会社', nick: '大熊', zip: '780-0811', address:'高知市弘化台１２番１２号', phone: '088-882-5111', repphone: '000-000-0000', fax: '088-883-2014', cost: 220.0, block_cost: 275.0, one_time_cost: 125.0, one_time_cost_description: "送信料・送金料", optional_cost: 400.0, optional_cost_description: "ドルフィンプラス送料", history: {},
products: Product.where(namae: [
'中袋（20入り）',  
'セル（坂越 30x4)']))
	# "Kansai" Continued
		Market.create(mjsnumber: 1272, namae: '株式会社うおいち滋賀', nick: '滋賀', zip: '520-2123', address:'滋賀県大津市瀬田大江町５９番の１　大津市公設地方卸売市場内', phone: '077-543-8322', repphone: '000-000-0000', fax: '077-543-0323', cost: 220.0, block_cost: 85.0, one_time_cost: 260.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
]))
		Market.create(mjsnumber: 1273, namae: '株式会社うおいち和歌山', nick: '和歌山', zip: '641-0036', address:'和歌山県和歌山市西浜１６６０－４０１　和歌山市中央卸売市場内', phone: '073-432-2525', repphone: '000-000-0000', fax: '073-432-2383', cost: 270.0, block_cost: 40.0, one_time_cost: 220.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'中袋（20入り）',
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1302, namae: '株式会社大水　京都支社', nick: '京都', zip: '600-8847', address:'京都府京都市下京区朱雀分木町市有地　京都市中央卸売市場内', phone: '075-321-2112', repphone: '000-000-0000', fax: '075-314-2672', cost: 270.0, block_cost: 50.0, one_time_cost: 335.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'100gレギュラーパック (30x1)', 
'100gレギュラーパック (30x2)', 
'100gレギュラーパック (20x3)', 
'100gレギュラーパック (20x2)', 
'100gレギュラーパック (20x1)',
'500gジャンボパック(12入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)',  
'大袋', 
'中袋（20入り）',
'セル（坂越 30x4)']))
		Market.create(mjsnumber: 1350, namae: '株式会社奈良魚市', nick: '奈良', zip: '639-1196', address:'奈良県大和郡山市筒井町９５７－１　奈良県中央卸売市場内', phone: '0743-56-7281', repphone: '000-000-0000', fax: '0743-56-7284', cost: 270.0, block_cost: 30.0, one_time_cost: 325.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500gジャンボパック(12入り)', 
'300gジャンボパック (12入り)', 
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'中袋（20入り）',
'セル（坂越 30x4)']))
	# "Shinkou" Kobe
		Market.create(mjsnumber: 1411, namae: '神港魚類株式会社', nick: '神港', zip: '652-0844', address:'兵庫県神戸市兵庫区中之島１丁目１番１号　神戸市中央卸売市場内', phone: '078-672-7001', repphone: '000-000-0000', fax: '078-671-5253', cost: 220.0, block_cost: 85.0, one_time_cost: 260.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)', 
'100gレギュラーパック (30x1)', 
'100gレギュラーパック (30x2)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'200g水切りパック (20x1)', 
'200g水切りパック (20x2)', 
'大袋', 
'中袋（20入り）', 
'セル（坂越 30x4)']))
Market.create(mjsnumber: 1412, namae: '神港魚類株式会社東部支社', nick: '神港東部', zip: '658-0023', address:'神戸市東灘区深江浜町1-1', phone: '078-413-7020', repphone: '000-000-0000', fax: '000-000-0000', cost: 220.0, block_cost: 85.0, one_time_cost: 260.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'100gレギュラーパック (30x1)', 
'100gレギュラーパック (30x2)', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'200g水切りパック (20x1)', 
'200g水切りパック (20x2)', 
'大袋', 
'中袋（20入り）', 
'セル（坂越 30x4)']))
Market.create(mjsnumber: 1412, namae: '神港魚類株式会社東部支社 明石行', nick: '明石', zip: '658-0023', address:'神戸市東灘区深江浜町1-1', phone: '078-413-7020', repphone: '000-000-0000', fax: '000-000-0000', cost: 220.0, block_cost: 85.0, one_time_cost: 260.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)']))
Market.create(mjsnumber: 1412, namae: '神港魚類株式会社東部支社 尼崎 森本行', nick: '尼崎', zip: '658-0023', address:'神戸市東灘区深江浜町1-1', phone: '078-413-7020', repphone: '000-000-0000', fax: '000-000-0000', cost: 220.0, block_cost: 85.0, one_time_cost: 260.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'中袋（20入り）', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)']))
	# Other local and special(new)
		Market.create(mjsnumber: 1450, namae: '株式会社岡山県水', nick: '岡山', zip: '702-8511', address:'岡山県岡山市南区市場１丁目１番地　岡山県中央卸売市場', phone: '086-265-2111', repphone: '000-000-0000', fax: '086-262-2292', cost: 270.0, block_cost: 50.0, one_time_cost: 485.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'1キロ弁当箱 (10入り)', 
'1キロ弁当箱 (8入り)', 
'1キロ弁当箱 (6入り)', 
'1キロ弁当箱 (5入り)', 
'1キロ弁当箱 (4入り)', 
'1キロ弁当箱 (2入り)', '中袋（20入り）', 
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)']))
		Market.create(mjsnumber: 1451, namae: '姫路魚類株式会社', nick: '姫路', zip: '670-0966', address:'兵庫県姫路市延末２９５番地　姫路市中央卸売市場内', phone: '079-221-6071', repphone: '000-000-0000', fax: '079-221-6074', cost: 240.0, block_cost: 45.0, one_time_cost: 230.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)', 
'中袋（20入り）']))
		Market.create(mjsnumber: 1452, namae: 'ペルゴセンター', nick: 'ペルゴ', zip: '679-4155', address:'龍野市揖保町揖保中３３５', phone: '0791-67-1333', repphone: '000-000-0000', fax: '0791-67-2500', cost: 0.0, block_cost: 0.0, one_time_cost: 0.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)']))
		Market.create(mjsnumber: 1453, namae: '株式会社吉村商店', nick: '福岡', zip: '810-0072', address:'福岡県福岡市中央区長浜3-11-3', phone: '092-711-6930', repphone: '000-000-0000', fax: '092-711-6930', cost: 600.0, block_cost: 0.0, one_time_cost: 110.0, one_time_cost_description: "送信料・送金料", optional_cost: 0.0, optional_cost_description: "-", history: {},
products: Product.where(namae: [
'120gワイドパック (20x3)', 
'120gワイドパック (20x2)', 
'120gワイドパック (20x1)',
'500g水切りパック (4x7)', 
'500g水切りパック (4x6)', 
'500g水切りパック (4x5)', 
'500g水切りパック (4x4)', 
'500g水切りパック (4x3)', 
'500g水切りパック (4x2)', 
'500g水切りパック (4x1)']))