import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/Erros/something_went_wrong.dart';
import '../../../data/cubits/Utility/fetch_transactions_cubit.dart';
import '../../../data/model/transaction_model.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/constant.dart';
import '../../../utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) {
            return FetchTransactionsCubit();
          },
          child: const TransactionHistory(),
        );
      },
    );
  }

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListener);

  late Map<int, String> statusMap;
  @override
  void initState() {
    context.read<FetchTransactionsCubit>().fetchTransactions();
    super.initState();
  }

  _pageScrollListener() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchTransactionsCubit>().hasMoreData()) {
        context.read<FetchTransactionsCubit>().fetchTransactionsMore();
      }
    }
  }

  @override
  void didChangeDependencies() {
    statusMap = {
      1: UiUtils.getTranslatedLabel(context, "statusSuccess"),
      2: UiUtils.getTranslatedLabel(context, "statusFail")
    };
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title: UiUtils.getTranslatedLabel(context, "transactionHistory")),
      body: BlocBuilder<FetchTransactionsCubit, FetchTransactionsState>(
        builder: (context, state) {
          if (state is FetchTransactionsInProgress) {
            return Center(
              child: UiUtils.progress(),
            );
          }
          if (state is FetchTransactionsFailure) {
            return const SomethingWentWrong();
          }
          if (state is FetchTransactionsSuccess) {
            if (state.transactionmodel.isEmpty) {
              return NoDataFound(
                onTap: () {
                  context.read<FetchTransactionsCubit>().fetchTransactions();
                },
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _pageScrollController,
                    itemCount: state.transactionmodel.length,
                    itemBuilder: (context, index) {
                      TransactionModel transaction =
                          state.transactionmodel[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                              color: context.color.secondaryColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                              contentPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      16, 5, 16, 5),
                              style: ListTileStyle.list,
                              subtitle: Row(
                                children: [
                                  Text(
                                    transaction.createdAt
                                        .toString()
                                        .formatDate(),
                                  ).size(context.font.small),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "${Constant.currencySymbol}${transaction.amount}"),
                                  Text(statusMap[int.parse(transaction.status)]
                                      .toString())
                                ],
                              ),
                              title: Row(
                                children: [
                                  Text(transaction.transactionId.toString()),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                      onTap: () async {
                                        await HapticFeedback.vibrate();
                                        var clipboardData = ClipboardData(
                                            text: transaction.transactionId);

                                        Clipboard.setData(clipboardData)
                                            .then((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(UiUtils
                                                      .getTranslatedLabel(
                                                          context, "copied"))));
                                        });
                                      },
                                      child: Icon(
                                        Icons.copy,
                                        size: context.font.larger,
                                      ))
                                ],
                              )),
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress()
              ],
            );
          }

          return Container();
        },
      ),
    );
  }
}
