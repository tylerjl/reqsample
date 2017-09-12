module ReqSample
  # These probabilities are purely random guesses
  RESPONSE_CODES = {
    '200' => 100,
    '204' => 1,
    '301' => 5,
    '302' => 10,
    '304' => 30,
    '400' => 3,
    '401' => 2,
    '403' => 6,
    '404' => 13,
    '429' => 3,
    '500' => 2,
    '502' => 7,
    '503' => 3,
    '504' => 3
  }.freeze
end
