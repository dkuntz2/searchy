class String
	def tokenize!
		if self.length == 0
			return
		end

		self.strip!
		self.downcase!

		while self.length > 0 and (self[0] < "a" or self[0] > "z") and (self[0] < "0" or self[0] > "9")
			self.slice!(0)
		end

		while self.length > 0 and (self[-1] < "a" or self[-1] > "z") and (self[-1] < "0" or self[-1] > "9")
			self.slice!(-1)
		end

		self
	end
end
