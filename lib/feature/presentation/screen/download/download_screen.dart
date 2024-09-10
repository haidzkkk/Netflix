
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/feature/commons/utility/file_util.dart';
import 'package:spotify/feature/commons/utility/utils.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: FileUtil.getListMovieDownload(),
        builder: (context, snapshot){
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index){
              var item = snapshot.data![index];

              return Container(
                padding: const EdgeInsetsDirectional.all(8),
                margin: const EdgeInsetsDirectional.all(8),
                color: Colors.brown,
                child: FutureBuilder(
                    future: item.getSize(),
                    builder: (context, snapshot){
                    return Text("${item.getName()} ${bytesToMb(snapshot.data?.toDouble() ?? 0.0).toStringAsFixed(1)} MB");
                  }
                ),
              );
            },
          );
        },
      ),
    );
  }
}
