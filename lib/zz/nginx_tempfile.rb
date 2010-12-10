module ZZ
  class NginxTempfile < File 
    def to_tempfile
     self
    end
  end
end