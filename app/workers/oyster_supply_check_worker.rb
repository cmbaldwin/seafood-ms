class OysterSupplyCheckWorker
	include Sidekiq::Worker

	def perform(oyster_supply_id, message_id)
		message = Message.find(message_id)
		supply = OysterSupply.find(oyster_supply_id)
		pdf_data = PrawnPDF.oyster_supply_check(supply)
		pdf = CarrierStringInvoiceIO.new(pdf_data.render)
		message.update(document: pdf)
		pdf_data = nil
		pdf = nil
		GC.start
		message.update(state: true, message: '牡蠣原料受入れチェック表作成完了。')
	end
end
