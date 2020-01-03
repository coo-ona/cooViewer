dic = {}
File.open("cooViewer.app.ad.txt", mode = "r"){|f|
  target_id = nil
  f.each_line{|line|
    if line =~ /<Position>(.*?)<\/Position>/
      target_id = $1
      dic[target_id] = []
    end
    if !target_id.nil? && line =~ /<base loc="en"\s*>(.*?)<\/base>/
      dic[target_id][0] = $1
    end
    if !target_id.nil? && line =~ /<tran loc="ja" origin="OldLoc exact match">(.*?)<\/tran>/
      dic[target_id][1] = $1
      target_id = nil
    end
  }
}
newja = ""
File.open("ja.xliff", mode = "r"){|f|
  target_id = nil
  source = nil
  f.each_line{|line|
    if line =~ /<trans-unit id="(.*?)" xml:space="preserve">/
      target_id = $1
    end
    if line =~ /<source>(.*?)<\/source>/
      source = $1
    end
    if !target_id.nil? && line =~ /<target>/ && !dic[target_id].nil? && dic[target_id][0]==source
      line = "        <target>#{dic[target_id][1]}</target>\n"
      target_id = nil
    end
    newja << line
  }
}
File.open("newja.xliff", mode = "w"){|f|
  f.write(newja)
}