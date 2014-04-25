gem 'test-unit'
require 'test/unit'
require 'steg-client/engine'

class TestEngine < Test::Unit::TestCase

  def setup
  end

  def test_encode
    # Setup
    options = {
        :knockcode          => 'knock',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    engine = Stegclient::Engine.new(options)
    message = 'mazinger rocks'
    expected = 'knock014mazinger rocks'

    # Act
    steganogram = engine.encode(message)

    # Assert
    assert_equal expected, steganogram
  end

  def test_decode_valid
    # Setup
    options = {
        :knockcode          => 'knock',
        :lengthsize         => 3,
        :fieldsize          => 256,
        :verbose            => true
    }
    engine = Stegclient::Engine.new(options)
    steganogram = 'knock020Goku i$ even cooler!'
    expected = 'Goku i$ even cooler!'

    #Act
    message = engine.decode(steganogram)

    #Assert
    assert_equal expected, message
  end

  def test_decode_invalid_length
    # Setup
    options = {
        :knockcode          => 'knock',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    engine = Stegclient::Engine.new(options)
    steganogram = 'knock025Goku i$ even cooler!'

    #Act
    message = engine.decode(steganogram)

    #Assert
    assert_true message.nil?
  end

  def test_decode_missing_knockcode
    # Setup
    options = {
        :knockcode          => 'knock',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    engine = Stegclient::Engine.new(options)
    steganogram = '020Goku i$ even cooler!'

    # Act
    message = engine.decode(steganogram)

    # Assert
    assert_true message.nil?
  end

  def test_extract_header
    # Setup
    options = {
        :port               => '10001',
        :knockcode          => 'knock',
        :outputmethod       => 'Header',
        :outputmethodconfig => 'X-Powered-By',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    headers = {
        'date'              => 'Thu, 24 Apr 2014 15:08:14 GMT',
        'server'            => 'Apache/2.4.9 (Fedora)',
        'x-powered-by'      => 'PHP/5.4.0knock024Spiddy is not bad thoughYesheis',
        'connection'        => 'close',
    }
    engine = Stegclient::Engine.new(options)
    expected = 'knock024Spiddy is not bad though'

    # Act
    steganogram = engine.extract(headers)

    # Assert
    assert_equal expected, steganogram
  end

  def test_inject_header
    # Setup
    options = {
        :port               => '10001',
        :knockcode          => 'knock',
        :inputmethod       => 'Header',
        :inputmethodconfig => 'Accept-Encoding',
        :lengthsize         => 3,
        :fieldsize          => 256,
    }
    headers = {
        'user-agent'        => ['curl/7.32.0'],
        'host'              => ['localhost'],
        'accept-encoding'   => ['gzip, deflate'],
        'proxy-connection'  => ['Keep-Alive'],
    }
    steganogram = 'knock024Spiddy is not bad though'

    expected = {
        'user-agent'        => ['curl/7.32.0'],
        'host'              => ['localhost'],
        'accept-encoding'   => ['gzip, deflateknock024Spiddy is not bad though'],
        'proxy-connection'  => ['Keep-Alive'],
    }
    engine = Stegclient::Engine.new(options)

    # Act
    engine.inject(steganogram, headers)

    # Assert
    assert_equal expected, headers
  end


end