import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs.dart';
import 'package:wefood/services/secure_storage.dart';

clearData(BuildContext context) async {
  context.read<UserInfoCubit>().delete();
  context.read<BusinessBreakfastCubit>().delete();
  context.read<BusinessLunchCubit>().delete();
  context.read<BusinessDinnerCubit>().delete();
  context.read<PendingOrdersBusinessCubit>().delete();
  context.read<RecommendedItemsCubit>().delete();
  context.read<NearbyItemsCubit>().delete();
  context.read<FavouriteItemsCubit>().delete();
  context.read<SearchFiltersCubit>().delete();
  context.read<OrderHistoryCubit>().delete();
  await UserSecureStorage().delete(key: 'accessToken');
  await UserSecureStorage().delete(key: 'accessTokenExpiresAt');
  await UserSecureStorage().delete(key: 'username');
  await UserSecureStorage().delete(key: 'password');
}