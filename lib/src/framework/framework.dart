/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// Created by changlei on 2020-02-13.
///
/// [State]和[Presenter]的抽象模板
abstract class StateMethods<T extends StatefulWidget> {
  /// 页面是否有效
  bool get mounted;

  /// 同state.widget
  T get widget;

  /// 同state.context
  BuildContext get context;

  /// 同state.initState
  void initState();

  /// 同state.didUpdateWidget
  void didUpdateWidget(covariant T oldWidget);

  /// 同state.reassemble
  void reassemble();

  /// 同state.deactivate
  void deactivate();

  /// 同state.dispose
  void dispose();

  /// 同state.didChangeDependencies
  void didChangeDependencies();

  /// 同state.setState
  void markNeedsBuild([VoidCallback? fn]);

  /// 页面在第一次绘制完成时回调
  void onPostFrame(Duration timeStamp);

  /// 页面动画执行完成或者完全稳定以后，在[onPostFrame]之后执行
  void onStabled();

  /// 隐藏键盘
  void hideKeyboard();
}

/// [StateMethods]的[State]具体实现类
abstract class CompatibleState<T extends StatefulWidget> extends State<T> implements StateMethods<T> {
  Animation<double>? _animation;

  @protected
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback(_onPostFrame);
  }

  @protected
  @mustCallSuper
  @override
  void dispose() {
    _animation?.removeStatusListener(_onAnimationStatusChanged);
    _animation = null;
    super.dispose();
  }

  @protected
  @mustCallSuper
  @override
  void onPostFrame(Duration timeStamp) {}

  @protected
  @mustCallSuper
  @override
  void onStabled() {}

  @protected
  @mustCallSuper
  @override
  void markNeedsBuild([VoidCallback? fn]) {
    if (!mounted) {
      return;
    }
    setState(fn ?? () {});
  }

  @protected
  @mustCallSuper
  @override
  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _onPostFrame(Duration timeStamp) {
    onPostFrame(timeStamp);
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) {
      onStabled();
    } else {
      animation.addStatusListener(_onAnimationStatusChanged);
      _animation = animation;
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    _animation?.removeStatusListener(_onAnimationStatusChanged);
    _animation = null;
    onStabled();
  }
}

/// 用来绑定[Presenter]和[State]
mixin HostProvider on StatefulWidget {
  @override
  HostStatefulElement createElement() => HostStatefulElement(this);

  @override
  HostState<StatefulWidget, Presenter<StatefulWidget>> createState();

  /// presenter
  @protected
  @factory
  Presenter<StatefulWidget> createPresenter();
}

/// 用来绑定[Presenter]和[State]
abstract class HostStatefulWidget extends StatefulWidget with HostProvider {
  /// Initializes [key] for subclasses.
  const HostStatefulWidget({Key? key}) : super(key: key);
}

/// An [Element] that uses a [HostStatefulWidget] as its configuration.
class HostStatefulElement extends StatefulElement {
  /// Creates an element that uses the given widget as its configuration.
  HostStatefulElement(HostProvider widget)
      : presenter = widget.createPresenter(),
        super(widget) {
    assert(() {
      if (!presenter._debugTypesAreRight(widget)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('HostStatefulWidget.createPresenter must return a subtype of Presenter<${widget.runtimeType}>'),
          ErrorDescription('The createPresenter function for ${widget.runtimeType} returned a presenter '
              'of type ${presenter.runtimeType}, which is not a subtype of '
              'Presenter<${widget.runtimeType}>, violating the contract for createPresenter.'),
        ]);
      }
      return true;
    }());
    final presenterState = state as HostState<StatefulWidget, Presenter<StatefulWidget>>;
    assert(
      presenter._state == null,
      'The createPresenter function for $widget returned an old or invalid presenter '
      'instance: ${presenter._state}, which is not null, violating the contract '
      'for createPresenter.',
    );
    presenter._state = presenterState;
    assert(
      presenterState._presenter == null,
      'The createPresenter function for $widget returned an old or invalid presenter '
      'instance: ${presenterState._presenter}, which is not null, violating the contract '
      'for createPresenter.',
    );
    presenterState._presenter = presenter;
  }

  /// The [Presenter] instance associated with this location in the tree.
  ///
  /// There is a one-to-one relationship between [Presenter] objects and the
  /// [HostStatefulElement] objects that hold them. The [Presenter] objects are created
  /// by [HostStatefulElement] in [mount].
  final Presenter<StatefulWidget> presenter;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Presenter<StatefulWidget>>('presenter', presenter, defaultValue: null));
  }
}

/// 用来绑定state和presenter
abstract class HostState<T extends StatefulWidget, P extends Presenter<T>> extends CompatibleState<T> {
  P? _presenter;

  /// presenter
  P get presenter {
    assert(() {
      if (_presenter == null) {
        if (widget is! HostProvider) {
          throw FlutterError('The ${widget.runtimeType} must be a subtype of HostProvider.');
        } else {
          throw FlutterError('The createPresenter function for $widget returned an old or invalid presenter '
              'instance: $_presenter, which is not null, violating the contract '
              'for createPresenter.');
        }
      }
      return true;
    }());
    return _presenter!;
  }

  @mustCallSuper
  @protected
  @override
  void initState() {
    super.initState();
    presenter.initState();
  }

  @mustCallSuper
  @protected
  @override
  void onPostFrame(Duration timeStamp) {
    super.onPostFrame(timeStamp);
    presenter.onPostFrame(timeStamp);
  }

  @mustCallSuper
  @protected
  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    presenter.didUpdateWidget(oldWidget);
  }

  @mustCallSuper
  @protected
  @override
  void reassemble() {
    super.reassemble();
    presenter.reassemble();
  }

  @mustCallSuper
  @protected
  @override
  void deactivate() {
    super.deactivate();
    presenter.deactivate();
  }

  @mustCallSuper
  @protected
  @override
  void dispose() {
    super.dispose();
    presenter.dispose();
  }

  @mustCallSuper
  @protected
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    presenter.didChangeDependencies();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Presenter<T>>('_presenter', _presenter, ifNull: 'no presenter'));
  }
}

/// 绑定在[State]上处理逻辑
abstract class Presenter<T extends StatefulWidget> implements StateMethods<T> {
  /// 绑定的state
  StateMethods<T>? _state;

  @protected
  @mustCallSuper
  @override
  bool get mounted => _state!.mounted;

  @protected
  @mustCallSuper
  @override
  T get widget => _state!.widget;

  @protected
  @mustCallSuper
  @override
  BuildContext get context => _state!.context;

  /// [RouteSettings]
  @protected
  @mustCallSuper
  RouteSettings? get settings => ModalRoute.of(context)?.settings;

  /// 上级页面传过来的参数，可能为null
  @protected
  @mustCallSuper
  dynamic get arguments => settings?.arguments;

  @mustCallSuper
  @override
  void initState() {}

  @mustCallSuper
  @override
  void didUpdateWidget(covariant T oldWidget) {}

  @mustCallSuper
  @override
  void reassemble() {}

  @mustCallSuper
  @override
  void deactivate() {}

  @mustCallSuper
  @override
  void dispose() {}

  @mustCallSuper
  @override
  void didChangeDependencies() {}

  @protected
  @mustCallSuper
  @override
  void markNeedsBuild([VoidCallback? fn]) => _state?.markNeedsBuild(fn);

  @mustCallSuper
  @override
  void onPostFrame(Duration timeStamp) {}

  @mustCallSuper
  @override
  void onStabled() {}

  @protected
  @override
  void hideKeyboard() => _state?.hideKeyboard();

  /// Verifies that the [Presenter] that was created is one that expects to be
  /// created for that particular [Widget].
  bool _debugTypesAreRight(Widget widget) => widget is T;
}
