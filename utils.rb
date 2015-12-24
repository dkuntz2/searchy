class String
	def tokenize!
		if self.length == 0
			return
		end

		self.strip!
		self.downcase!

		while self.length > 0 and !self[0].match(/^[[:alpha:]]$/)
			self.slice!(0)
		end

		while self.length > 0 and !self[-1].match(/^[[:alpha:]]$/)
			self.slice!(-1)
		end

		self
	end
end
