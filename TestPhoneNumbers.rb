def extract_phone_number(input)
  firstCharIndex = input =~ /[a-zA-Z#]/
  number         = input[0..firstCharIndex-1]
  return clean_phont_number(number)
end

def clean_phone_number(input)
  if input.gsub(/\D/, "").match(/^1?(\d{3})(\d{3})(\d{4})/)
    [$1, $2, $3].join()
  end
end
